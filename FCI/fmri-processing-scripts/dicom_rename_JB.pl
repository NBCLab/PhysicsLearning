#!/usr/bin/perl -w

#work on current dir unless otherwise noted
@ARGV = qw(.) unless @ARGV;

use File::Find;
use File::Copy;
use Cwd;
use English;

sub process_file {

	#only want files
	return unless -f ;
	
	$image = "";
	$instance = "";
    #	$x = ""; $y = ""; $z = "";
	
	open (DICOM, "dicom_hdr $_ |") or die "Couldn't run the DICOM header program";
	#pull out revelant DICOM fields
	while (<DICOM>) {
		chomp;
		
		#if not a DICOM file
		return if (/ERROR. can.t open \w+ as a DICOM file/);

		#if (/ID Accession Number/) {
		#	($a,$b,$session) = split('/+');
		#	 $session = "0" if ($session eq "");
		#}
		if (/ID Study Date/) {
			($a,$b,$studydate) = split('/+');
			$studydate = "00000000" if ($studydate eq "") ;
		}
        
        if (/PAT Patient Name/) {
            ($a,$b,$pat) = split('/+'); #Not sure what this line does, so I’ll leave it as is
            $sep = '_';
            $lastloc = rindex($pat, $sep); #find the index FROM THE END OF THE STRING of the last occurrence of ‘_’
            $patID = substr( $pat, $lastloc+1, length($pat)-$lastloc );
        }
        
        #if (/PAT Patient ID/) {                     #MTS (10/20/15): use /Pat Patient ID/ instead of /PAT Patient Name/ Given change in how participant info entered at scaner console
        #	($a,$b,$pat) = split('/+');
        #	#print $a, "  ", $a, "  ", $pat,"\n";
        #	($x, $y, $z, $patID) = split('_', $pat);
        #	$patID = "0" if ($patID eq "");
        #	$patID =~ tr/P//d;  #MTS (10/20/15): delete the P character before the participant number that may have been entered at the scanner console 10/20/15
        #	#print $x, "  ", $y, "  ", $z,"  ", $patID,"\n";
        #}
		
		if (/ACQ Protocol Name/) {
			($a,$b,$prot) = split('/+');
			$prot = "0" if ($prot eq "");
		}

		if (/ID Series Description/) {
			($a,$b,$serdesc) = split('/+');
			$serdesc = "NODESCRIPTION" if ($serdesc eq "") ;
		}
		if (/REL Series Number/) {
			($a,$b,$sernum) = split('/+');
			$sernum = "0" if ($sernum eq "") ;
		}


		if (/REL Acquisition Number/) {
			($a,$b,$acq) = split('/+');
			$acq = "0" if ($acq eq "") ;
		}
		if (/REL Image Number/) {
			($a,$b,$image) = split('/+');
		}
		if (/REL Instance Number/) {
			($a,$b,$instance) = split('/+');
		}

	}
	close (DICOM);
	#in jan 2004 REL Image became REL Instance
	if (!defined $image || $image eq "") {
		if (!defined $instance || $instance eq "") {
			$image = "0";
		} else {
			$image = $instance;
		}
	}
	#create protocol, subject, session, series, image - strip out any spaces and change carets to underscores
	$prot =~ s/\s//g;
	$prot =~ s/\^/_/g;
	$patID =~ s/\s//g;
	$patID =~ s/\^/_/g;
	$study = $studydate;
	#$study = $session . "-" . $studydate;
	$study =~ s/\s//g;
	$study =~ s/\^/_/g;
	$series = $sernum . "-" . $serdesc;
	$series =~ s/\s//g;
	$series =~ s/\^/_/g; 

	#zeropad acq and image by reversing, adding zeros, re-reversing and taking the last chars
	$acq =~ s/\s//g;
	$acq =~ s/\^/_/g;
	$acq = reverse($acq)."0000000000";
	$acq = substr(reverse($acq), -5);
	$image =~ s/\s//g;
	$image =~ s/\^/_/g;
	$image = reverse($image)."0000000000";
	$image = substr(reverse($image), -6);
	$im = $acq . "-" . $image;
	
	if (! -e $parentdir."/".$prot) {
		mkdir($parentdir."/".$prot, 0777) || die "couldn't create a directory for $prot  :$!\n";
	}
	if (! -e $parentdir."/".$prot."/".$patID) {
		mkdir($parentdir."/".$prot."/".$patID, 0777) || die "couldn't create a directory for $patID  :$!\n";
	}
	if (! -e $parentdir."/".$prot."/".$patID."/".$study) {
		mkdir($parentdir."/".$prot."/".$patID."/".$study, 0777) || die "couldn't create a directory for $study  :$!\n";
	}
	if (! -e $parentdir."/".$prot."/".$patID."/".$study."/".$series) {
		mkdir($parentdir."/".$prot."/".$patID."/".$study."/".$series, 0777) || die "couldn't create a directory for $series  :$!\n";
	}

	move($parentdir."/".$File::Find::name, $parentdir."/".$prot."/".$patID."/".$study."/".$series."/image-".$im.".dcm") || die "couldn't copy files $!\n";
	#print $prot, "  ", $patID, "  ", $study, "  ", $series,"  ", $im,"\n";
}

umask 0022;
$parentdir = cwd();
find(\&process_file, @ARGV);

foreach $direc (@ARGV) {
	`find $direc -depth -type d -exec rmdir \{\} \\;` ;
}

