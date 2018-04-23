# gawk script
# Many big Swagger files do not have operationId defined for each operation.
# This script adds an operationId for each op by combining the 'path' and 'method' for each operation
# Eg.
# Original:
# /api/1:
#  get:
#    ...
#  post:
#    ...
#
# Modified as:
# /api/1:
#  get:
#    operationId: api_1_get
#    ...
#  post:
#    operationId: api_1_post
#    ...


BEGIN {print "Hello";}

{
  eof=1 # Setting eof to 1; 0 means EOF is hit
  print $0 # Print the first line

  do {
    match($0,/^  ['\''\"]?\/([^'\''\"]*)['\''\"]?:/, a) # Check if the line is a path i.e api/v1/1
    if (length(a)!=0){ # If length is not zero means that he path was captured in the previous match
      split(a[1],b,/\//) # Splitting the path with '/' as delimiter
      opId= b[1]
      for (i=2;i<=length(b);i++){
        if (length(b[i])!=0){ opId= opId "_" b[i];} # Building the operationId
      }
      eof=getline # Get the next line and print if not EOF
      if (eof==0) exit
      print $0
      match($0,/^(  ['\''\"\/])/, path) # Proceed only if the line is not a path; if it's a path continue to next iteration
      while (length(path)==0) {
        match($0,/^    (get|put|post|delete):/,c) # If line was a method(get/put/post..), add it to operationId
        if(length(c)>0) {
          thisOpId="\"" opId "_" c[1] "\""
          print "      operationId:" thisOpId # Print the operationId
        }
        eof=getline # Get next line and reiterate
        if (eof==0) exit
        print $0
        match($0,/^(  ['\''\"\/])/, path)
      }
    } else {
      next # Incase the line was not a path, get next line and move on
    }
  } while (eof!=0)

}

END {print "End";}
