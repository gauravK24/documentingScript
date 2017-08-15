#!/usr/bin/perl

use File::Find::Rule;

#< or r	Read Only Access
#> or w	 Creates, Writes, and Truncates
#>> or a	Writes, Appends, and Creates
#+< or r+	Reads and Writes
#+> or w+	Reads, Writes, Creates, and Truncates
#+>> or a+	Reads, Writes, Appends, and Creates

#askUser ();

$path = "/Users/gauravkumar/Documents/Demo_Apps/TreasureHuntApp1";

# Read directory from the path provided.
my $rule = File::Find::Rule->new;
$rule->file;
$rule->name( '*.m' );
my @files = $rule->in($path);


#opendir(DIR, "$path");
#@files = grep(/\.m$/,readdir(DIR));
#closedir(DIR);


# Iterate through all files.
foreach $fi (@files) {
    
    #Get the fileName.
    my $fileName = "$fi";
    
    #Make new name for the file opened for writing (with _).
    my @arr = split("/",$fi);
    my $len = scalar (@arr);
    
    my $org = $arr[$len-1];
    my $rep = "_$org";
    
    $fi =~ s/$org/$rep/;
    
    my $newName = "$fi";

    open (DATA_R, "<$fileName") || die "Cant open file for READING";
    open (DATA_W, ">$newName") || die "Cant open file for WRITING";

    $syntx = "-";

    while ($text = <DATA_R>) {
     
        # Split the text by newline.
        @words = split("\n", $text);
        
        for $val (@words) {
            
            #Check For Curly braces in the line - Maintain a stack for that
            checkForCurlyBraces ($val);
            
            
            
            
            
            # METHOD LINE IDENTIFICATION -----
            if( $val =~ /^(\-|\+)[()]*/ ) {
                
                # Split the word by ":".
                my @txtSeg = split(":", $val);
                
                #Get the count.
                $arrCount = scalar(@txtSeg);
                
                #Check if it has one or more than values.
                #CONDITION 1 - Only one value i.e. just return type
                
                if($arrCount == 1) {
                    $comment = checkForReturnType(@txtSeg);
                }
                
                #CONDITION 2 - More than one value i.e. arguments present

                else {
                    $comment = checkForArgs(@txtSeg);
                }
                
                #print "COMMENT ----- $comment \n";
                #Write the comment to other file.
                print DATA_W "\n/*\n$comment\n*/\n";
            }
            
            #Write to other textFile.
            print DATA_W "$val\n";
        }
    }

    # Close the file handlers ---
    close (DATA_R);
    close (DATA_W);

    #delete the oldFile.
    unlink $fileName;

    #rename the newFile with oldFile name.
    rename $newName,$fileName;

    #    print "Outside of while loop\n";
}


sub checkForCurlyBraces {
    my @arrTxt = @_;

    if( $arrTxt[0] =~ /^[{]/ ) {
        print "CURLY BRACES  $x ----- @y ------- $y[0] \n";
    }
}


#Method called for CONDITION-1.
#Method called when there is only one argument in the method i.e return type.
sub checkForReturnType {
    my @arr = @_;

    # Take out the method desc --- starting from ) to {
    my @strDesc = removeCurlyBraces ($val);
    
    # Get argument array.
    my @arrR = getArgs (@arr);
        
    #Make Comment.
    my $comment = getDescComment (\@strDesc, \@arrR);
    return ($comment);
}

#Remove from curly braces from last argument or method name.
sub removeCurlyBraces {
    my @arrStr = @_;

    my @arr = ( $arrStr[0] =~ /\)(.*)/ );
    my $str = $arr[0];
    
    if( $str =~ "{" ) {
        @arr = ( $str =~ /(.*)\{/ );
    }
    
    return (@arr);
}

    
#Method called for CONDITION-2.
#Method called when there is more than one argument in the method.
sub checkForArgs {
    my @arr = @_;

    # Take out the method desc --- starting from ) to first :
    #my @strDesc = ( $val =~ /\)(.*):/ );
    my @strDesc = ( $arr[0] =~ /\)(.*)/ );
    
    # Get argument array.
    my @arrA = getArgs (@arr);
    
    #Make Comment.
    my $comment = getDescComment (\@strDesc, \@arrA);

    # Create arguments comment by looping for all args types.
    my $comArgs = "";
    for ($i=1; $i<$arrCount; $i++) {
        
        #Get Params Comment.
        my @arrComP = ( $arr[$i] =~ /\)(.*)\s/ );
        if($i == $arrCount-1) {
            @arrComP = removeCurlyBraces ($arr[$i]);
            #@arrComP = ( $arr[$i] =~ /\)(.*){/ );
        }

        my $comP = "* Params $i: $arrComP[0]";
        my $comA = "* Args $i: $arrA[$i]";
        $comArgs = join ("\n", $comArgs, $comA, $comP);
    }

    # Making a final comment by joining the comms
    $commentF = join ("\n", $comment, $comArgs);
    
    return ($commentF);
}
    

#Method to join comments.
sub getDescComment {
    
    my ($one_ref, $two_ref) = @_;
    
    my @arrD = @{$one_ref};
    my @arrA = @{$two_ref};
    
    #Joining Desc and return type for comment.
    my $comD = "* Method Description: $arrD[0]";
    my $comR = "* Method return type: $arrA[0]";
    my $comment = join ("\n", $comD, $comR);
    
    return ($comment);
}
    
    
#Method to get argument array.
sub getArgs {
    
    my @arr = @_;
    
    undef @arrArgs;
    
    #Clip the brackets from the args.
    for $arg (@arr) {
        @arrTemp = ( $arg =~ /\((.*)\)/ );
        push (@arrArgs, $arrTemp[0]);
    }
    
    return (@arrArgs);
}
    
