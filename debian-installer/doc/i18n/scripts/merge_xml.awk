# The script keeps track of some special situations:
# - 'tags' in comments are not handled well by poxml tools, so these
#   are removed
# - references within comments should not be processed, so we keep
#   a count of opening and closing of comments

BEGIN {
    main_count = 1
    
    # Let's first build an array with all the entities (xml files)
    while (getline <ENTLIST) {
        delim = index($0, ":")
        i = substr($0, 1, delim - 1)
        
        fname = substr($0, delim + 1, length($0) - delim)
        # Trim any leading and trailing space of filenames
        gsub(/^[[:space:]]*/, "", fname)
        gsub(/[[:space:]]*$/, "", fname)

        ent [i] = fname
        included [i] = 0
    }
}

{
    # In the main loop we only want to process entities that are refered to
    line = $0
    if (match (line, /^[[:space:]]*&.*\.xml;[[:space:]]*(<\!--.*-->[[:space:]]*|)*$/) > 0) {
        process_file(line, "main")
    }
}

END {
    print "" >>LOG
    print "The following defined entities (from docstruct) were NOT processed:" >>LOG
    for (entname in ent) {
        if (included [entname] == 0) {
            print "  " entname >>LOG
        }
    }
}

function process_file(entline, level,   fname, tfname) {
        entname = get_entname(entline)
        if (entname in ent) {
            fname = ent [entname]
            print "Processing: " fname >>LOG
            INFILE = WORKDIR "/in/" fname

            if (level == "main") {
                main_count += 1

                # Change at highest level: change to a new output file
                OUTFILE = WORKDIR "/out/" fname
                OUTDIR = OUTFILE
                gsub(/\/[^\/]*$/, "/", OUTDIR) # strip filename
                system("mkdir -p " OUTDIR)     # create directory
            } else {
                print "" >>OUTFILE
            }

            if (level == "sub" && included [entname] != 0 && included [entname] < main_count) {
                print "** Warning: entity '" entname "'was also included in another file." >>LOG
            }
            if (level == "main") {
                included [entname] = 1
            } else {
                included [entname] = main_count
            }
            parse_file(INFILE, fname)

        } else {
            print "** Entity " entname " not found and will be skipped!" >>LOG
            print entline >>OUTFILE
        }
}

function parse_file(PARSEFILE, FNAME,   fname, nwline, comment_count) {
    comment_count = 0
    fname = FNAME
    
    # Test whether file exists
    getline <PARSEFILE
    if (ERRNO != 0) {
        print "** Error: file '" PARSEFILE "' does not exist!" >>LOG
        return
    }
    
    print "<!-- Start of file " fname " -->" >>OUTFILE
    while (getline <PARSEFILE) {
        nwline = $0

        # Update the count of 'open' comments
        comment_count += count_comments(nwline)

        if (match(nwline, /^[[:space:]]*&.*\.xml;[[:space:]]*(<\!--.*-->[[:space:]]*|)*$/) > 0) {
            # If we find another entity reference, we process that file recursively
            # But not if the reference is within a comment
            if (comment_count != 0) {
                print "** Skipping entity reference '" nwline "' found in comment!" >>LOG
            } else {
                process_file(nwline, "sub")
            }
        } else {
            # Else we just print the line
            if (match(nwline, /<\!--.*<.*>.*<.*>.*-->/) > 0) {
                # Comments containing "<...> ... <...>" are not handled correctly
                # by xml2pot and split2po, so we skip lines like that
                # Note: this is a workaround for a bug in the tools:
                #       http://bugs.kde.org/show_bug.cgi?id=90294
                print "** Comment deleted in line '" nwline "'" >>LOG
                gsub(/<\!--.*<.*>.*<.*>.*-->/, "", nwline)
            }
            print nwline >>OUTFILE
        }
    }
    if (comment_count != 0) {
        print "** Comment count is not zero at end of file: " comment_count >>LOG
    }
    print "<!--   End of file " fname " -->" >>OUTFILE
    close(PARSEFILE)
}

function get_entname(entline,   ename) {
    # Parse the name of the entity out of the entity reference
    ename = entline
    gsub(/^[[:space:]]*&/, "", ename)
    gsub(/;.*$/, "", ename)
    return ename
}

function count_comments(inline,   tmpline, count) {
    # 'abuse' gsub to count them
    tmpline = inline
    count += gsub(/<\!--/, "", tmpline)
    count -= gsub(/-->/, "", tmpline)
    return count
}
