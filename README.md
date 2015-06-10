CasperMachineMigrator
=====================

If you are replacing a user's Mac or doing a larger hardware refresh, this is a tool to migrate the static inventory information of one Mac JSS record to another.

**Please Note:** Please test thoroughly before using in your own environment! Amsys will accept no responsibility for loss or damage caused by this script.

This script can migrate all text field Extension Attributes, drop-down menu Extension Attributes and user and location information from one JSS computer record to another.  The script can be run on a single line to move one record to another:

	./CasperMachineMigrator -v -s Amsys-123 -d Amsys-321 -c https://jss.amsys.co.uk:8443 -u darren -p 'password'

It can also be used with a tab delimited file to migrate the data for multiple records at once

	./CasperMachineMigrator -v -c https://jss.amsys.co.uk:8443 -u darren -p 'password' -f /Users/Shared/TabFile

Notes:

- Static group assignments aren't currently migrated (this is on the to-do list)
- Script populated EAs aren't migrated as they are dynamically generated during inventory collections
- If more than one result is found for either the source or destination computer, the script will exit

Running the script with no options will display the below help information:

	Usage: $0 [-v] -s SourceComputer [-h] [-d DestinationComputer] [-c CasperURL] [-u APIUsername] [-p APIPassword | -P] [-n] [-f PathToFile]
	
	-v						Verbose mode. Output all the things
	-s SourceComputer		Supply an identifier to use as the source of the information.
							This can be Computer Name, Serial Number, Asset Number or another unique identifier.
							If this finds more than one match it will exit.
	-d DestinationComputer 	Supply an identifier to use as the destination of the information to import the source computer's details into.
	-c CasperURL			Supply the Casper URL to contact for the work. if not specified, then the default set 
							in the script will be used.
	-u APIUsername			Supply the API username to access the Casper server and carry out the work.
	-p APIPassword 			Supply the API Password to access the Casper server and carry out the work.
							ENCLOSE ALL PASSWORDS IN SINGLE QUOTES ' ' TO ENSURE CHARACTERS ARE PASSED CORRECTLY!
							Also please do not use the following characters for passwords:
							\ 	' 	£ 	" 	` 	% 	~
	-P						The API Password will be requested.
	-n						Do not prompt to carry out the export/import, just do it!
	-f PathToFile			Use a tab delimited file to specify multiple source and destination Macs to work on.
	-h						This help message
	
	
	API PERMISSIONS:	These MUST be allowed for the specified API user:
					-	'JSS Objects'	-
			-	'Computer Extension Attributes' - Allow 'Read'
			-	'Computers'	- Allow 'Read' & 'Update'
			

Below is an example of the tab delimited file required for batch migrations:

	00001	00002
	00001	00003
	00001	00004

