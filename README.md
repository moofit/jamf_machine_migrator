CasperMachineMigrator
=====================


Tool to migrate the contents of one Mac record to another.

e.g. a replacement Mac for a User. This will migrate the location info and the non-script populated Extension Attributes



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
