CasperMachineMigrator
=====================

If you are replacing a user's Mac or doing a larger hardware refresh, this is a tool to migrate the static inventory information of one Mac JSS record to another.

This script can migrate all text field Extension Attributes, drop-down menu Extension Attributes and user and location information from one JSS computer record to another.  The script can be run on a single line to move one record to another:

	./CasperMachineMigrator -v -s Amsys-123 -d Amsys-321 -c https://jss.amsys.co.uk:8443 -u darren -p password

It can also be used with a tab delimited file to migrate the data for multiple records at once

	./CasperMachineMigrator -v -c https://jss.amsys.co.uk:8443 -u darren -p password -f /Users/Shared/TabFile

Notes:

- Static group assignments aren't currently migrated (this is on the to-do list)
- Script populated EAs aren't migrated as they are dynamically generated during inventory collections

Running the script with no options will display the below help information:

	Usage: CasperMachineMigrator [-v] -s SourceAssetNumber [-h] [-d DestinationAssetNumber] [-c CasperURL] [-u APIUsername] [-p APIPassword | -P] [-n] [-f PathToFile]
	
	-v				Verbose mode. Output all the things
	-s SourceAssetNumber		Supply an Asset Number to use as the souce of the information.
					Wildcards can be used with a *
					E.g. to find all begining with 'tes..' use "tes*"
					This will also take Serial Numbers, Departments, Buildings etc,
					however this can increase the likelihood of multiple matches
	-d DestinationAssetNumber 	Supply a specifc Asset Number to import the source computer's details into.
	-c CasperURL			Supply the Casper URL to contact for the work. if not specified, then the default set 
					in the script will be used.
	-u APIUsername			Supply the API username to access the Casper server and carry out the work.
	-p APIPassword 			Supply the API Password to access the Casper server and carry out the work.
					ENCLOSE ALL PASSWORDS IN SINGLE QUOTES ' ' TO ENSURE CHARACTERS ARE PASSED CORRECTLY!
					Also please do not use the following characters for passwords:
					\\ 	' 	£ 	\" 	\` 	% 	~
	-P				The API Password will be requested.
	-n				Do not prompt to carry out the export/import, just do it!
	-f PathToFile			Use a tab delimited file to specify multiple source and destination Macs to work on.
	-h				This help message
	
	
	API PERMISSIONS:	These MUST be allowed for the specified API user:
					-	'JSS Objects'	-
			-	'Computer Extension Attributes' - Allow 'Read'
			-	'Computers'	- Allow 'Read' & 'Update'
