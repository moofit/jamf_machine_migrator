#!/bin/sh

#############################################################################################
#																							#
#		Amsys Casper Machine Migrator														#
#																							#
#		- This script is designed to help migrate location information and EAs				#
#			from one Casper computer record to another, such as when kit is replaced -		#
#																							#
#		Current Version:	1.7																#
#		Version history:																	#
#		-	1.7	- DW - 23/12/14 -	Added in support for a tab-delimited file				#
#		-	1.6	- DW - 23/12/14 -	Added in help info about API Permissions				#
#		-	1.5	- DW - 23/12/14 -	Tests API authentication first							#
#		-	1.4	- DW - 23/12/14	-	Better accepts complex PWs and defaults to prompting	#
#		-	1.3	- DW - 23/12/14	-	Now imports the EAs and location info to the dest Comp!	#
#		-	1.2	- DW - 22/12/14	-	Added more flags and options.							#
#		-	1.1	- DW - 22/12/14	-	Now does command line arguments properly.				#
#		-	1.0 - DW - 22/12/14	-	Accepts an asset number to show location info and any	#
#			EA's that are not set by a script.												#
#																							#
#																							#
#############################################################################################

######################################## Variables ##########################################

SuppliedCasperURL="https://casper.example.com:8443"
SuppliedAPIUser="Optional-API-Username-Here"
set -f
SuppliedAPIPass='Optional-API-Password-Here'
set +f

############################### Do not change - Variables ####################################

# Sets default values. Shouldn't be need but just in case!
MinimumItems=1
verbose="off"
SOURCECOMPUTER=""
DESTINATIONCOMPUTER=""
AskForAPIPassword="no"
NoPrompt="no"
CSVPath=""

######################################## Functions ##########################################

function usage {
		echo "
		
Usage: $0 [-v] -s SourceAssetNumber [-h] [-d DestinationAssetNumber] [-c CasperURL] [-u APIUsername] [-p APIPassword | -P] [-n] [-f PathToFile]
	
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

"
		exit 1
		}


########################################## Script ###########################################

################################## Faff with the inputs #####################################

# Get Arguments / flags
while getopts 'hs:vd:c:u:p:Pnf:' flag; do
  case "${flag}" in
    h) usage ;;
    s) SOURCECOMPUTER="${OPTARG}" ;;
    v) verbose='on' ;;
    d) DESTINATIONCOMPUTER="${OPTARG}" ;;
    c) CasperURL="${OPTARG}" ;;
    u) APIUser="${OPTARG}" ;;
    p) set -f; APIPass="${OPTARG}"; set +f ;;
    P) AskForAPIPassword="yes";;
    n) NoPrompt="yes";;
    f) CSVPath="${OPTARG}"; NoPrompt="yes";;
    *) echo "Unexpected option ${flag}"
    	usage;;
  esac
done

########
# Check if verbose mode has been turned on
if [ $verbose = on ]
	then
		echo "VERBOSE MODE ON"
fi

########
# Check that at least one option has been provided
if [ $# -lt "$MinimumItems" ]
	then
		usage
fi

########
# See if override casper url has been specified
if [ "$CasperURL" = "" ]
	then
		CasperURL="$SuppliedCasperURL"
fi
CasperURL=${CasperURL%/}

########
# See if override casper API Username has been specified
if [ "$APIUser" = "" ]
	then
		APIUser="$SuppliedAPIUser"
fi

########
# See if override casper API Password has been specified
set -f
if [ "$APIPass" = "" ]
	then
		APIPass="$SuppliedAPIPass"
fi
set +f

########
# Request the API Password
set -f
if [ "$AskForAPIPassword" = "yes" ]
	then
		read -s -p "Enter Password: " mypassword
		APIPass="$mypassword"
fi
set +f

########
# Check if a CSV file has been specified
if [[ $CSVPath != "" ]]
	then
		echo "CSV File provided."
		counter=`grep -cve '^\s*$' "$CSVPath"`
	else
		counter="1"
fi

while [ $counter -ne 0 ]
	do		
	if [[ $CSVPath != "" ]]
		then
			SOURCECOMPUTER="`sed -n "$counter"p "$CSVPath" | awk '{ print $1; }'`"
			DESTINATIONCOMPUTER="`sed -n "$counter"p "$CSVPath" | awk '{ print $2; }'`"
	fi	
	########
	# Echo out details
	echo "Supplied Source Asset number is: "$SOURCECOMPUTER""
	echo "Supplied Destination Asset number is: "$DESTINATIONCOMPUTER""
	echo "Supplied Casper Server URL is: "$CasperURL""

	#####
	# Swaps any spaces for %20
	SearchItem=$(echo $SOURCECOMPUTER | sed 's/ /%20/g')
	DestSearchItem=$(echo $DESTINATIONCOMPUTER | sed 's/ /%20/g')

	#################################### Do the actual work ################################

	#####
	# Test the provided API authentication works!
	testresult=$(curl -s -w "%{http_code}" -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers -X GET -o /dev/null)
	if [ $verbose = on ]
		then
			echo "VERBOSE: Checking provided details authenticate"
			echo "VERBOSE: Curl status code is $testresult"
	fi

	if [ $testresult = 401 ]
		then
			echo "ERROR"
			echo "ERROR: API Username / password combination failed to authenticate. Curl status code: $testresult"
			echo "ERROR: Re-check the Casper URL and other details provided. Also check the help page for possible unsupported characters in the password"
			usage
	fi

	if [ $testresult = 404 ]
		then
			echo "ERROR"
			echo "ERROR: The Casper Server couldn't find the requested URL. Curl status code: $testresult"
			echo "ERROR: Please investigate."
			usage
	fi

	if [ $testresult = 500 ]
		then
			echo "ERROR"
			echo "ERROR: The Casper Server had an internal error. Curl status code: $testresult"
			echo "ERROR: Please try again, or check the server is operational!"
			usage
	fi

	#####
	# Checking for number of matches in the JSS for the source computer
	if [ $verbose = on ]
		then
			echo "VERBOSE: Checking for source matches"
	fi
	CompIDnumber=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/match/"$SearchItem" -X GET | xpath '//computer/id' 2>&1 | awk -F'<id>|</id>' '{print $2}'| awk '/./' | grep -c [0-9])

	if [ "$CompIDnumber" == 0 ]
		then
			echo ""
			echo "Error 2: No source matches found, please try again"
			echo "Run the script with '-h' for more information on usage"
			echo ""
			exit 2
		else
			if [ "$CompIDnumber" -gt 1 ]
				then
					echo ""
					echo "Error 3: More than 1 source match found, please be more specific"
					echo "Run the script with '-h' for more information on usage"
					echo ""
					exit 3
			fi
	fi

	#####
	# Grab computer ID	
	if [ $verbose = on ]
		then
			echo "VERBOSE: Getting source Computer ID"
	fi	
	CompID=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/match/"$SearchItem" -X GET | xpath '//computer/id' 2>&1 | awk -F'<id>|</id>' '{print $2}'| awk '/./')
	if [ $verbose = on ]
		then
			echo "VERBOSE: Source Computer ID is: $CompID"
	fi	

	#####
	# Checking for number of matches in the JSS for the destination computer
	if [ $verbose = on ]
		then
			echo "VERBOSE: Checking for destination matches"
	fi
	DestCompIDnumber=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/match/"$DestSearchItem" -X GET | xpath '//computer/id' 2>&1 | awk -F'<id>|</id>' '{print $2}'| awk '/./' | grep -c [0-9])

	if [ "$DestCompIDnumber" == 0 ]
		then
			echo ""
			echo "Error 2: No destination matches found, please try again"
			echo "Run the script with '-h' for more information on usage"
			echo ""
			exit 2
		else
			if [ "$DestCompIDnumber" -gt 1 ]
				then
					echo ""
					echo "Error 3: More than 1 destination match found, please be more specific"
					echo "Run the script with '-h' for more information on usage"
					echo ""
					exit 3
			fi
	fi

	#####
	# Grab computer ID	
	if [ $verbose = on ]
		then
			echo "VERBOSE: Getting destination Computer ID"
	fi	
	DestCompID=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/match/"$DestSearchItem" -X GET | xpath '//computer/id' 2>&1 | awk -F'<id>|</id>' '{print $2}'| awk '/./')
	if [ $verbose = on ]
		then
			echo "VERBOSE: Destination Computer ID is: $DestCompID"
	fi	

	################################################## LOCATION INFO ##################################################

	#####
	# Grab found computer's Location information
	if [ $verbose = on ]
		then
			echo "VERBOSE: Grabbing specified computer's Location information"
	fi	
	LocationInfo=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET)

	#####
	# Work to make the Location info more pretty
	Username=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/username' 2>&1 | awk -F'<username>|</username>' '{print $2}'| awk '/./')
	Realname=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/real_name' 2>&1 | awk -F'<real_name>|</real_name>' '{print $2}'| awk '/./')
	EmailAddress=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/email_address' 2>&1 | awk -F'<email_address>|</email_address>' '{print $2}'| awk '/./')
	Position=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/position' 2>&1 | awk -F'<position>|</position>' '{print $2}'| awk '/./')
	Phone=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/phone' 2>&1 | awk -F'<phone>|</phone>' '{print $2}'| awk '/./')
	Department=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/department' 2>&1 | awk -F'<department>|</department>' '{print $2}'| awk '/./')
	Building=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/building' 2>&1 | awk -F'<building>|</building>' '{print $2}'| awk '/./')
	Room=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/Location -X GET | xpath '//computer/location/room' 2>&1 | awk -F'<room>|</room>' '{print $2}'| awk '/./')

	#####
	# Display Location information in XML
	if [ $verbose = on ]
		then
			echo "VERBOSE: Location Info: "$LocationInfo""
	fi	

	#####
	# Display Location information nicely 
	if [ $verbose = on ]
		then
			echo "VERBOSE: Owner's Username is: "$Username""
			echo "VERBOSE: Owner's Real Name is: "$Realname""
			echo "VERBOSE: Owner's Email Address is: "$EmailAddress""
			echo "VERBOSE: Owner's Position is: "$Position""
			echo "VERBOSE: Owner's Phone Number is: "$Phone""
			echo "VERBOSE: Owner's Department is: "$Department""
			echo "VERBOSE: Owner's Building is: "$Building""
			echo "VERBOSE: Owner's Room is: "$Room""
	fi	

	################################################## EA INFO ##################################################

	#####
	# Grab found computer's MAC Address
	if [ $verbose = on ]
		then
			echo "VERBOSE: Grabbing specified computer's MAC address"
	fi	
	MAC=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/id/$CompID/subset/General | xpath '//computer/general/mac_address' 2>&1 | awk -F'<mac_address>|</mac_address>' '{print $2}'| awk '/./' )
	if [ $verbose = on ]
		then
			echo "VERBOSE: MAC Address is: $MAC"
	fi	

	#####
	# Grab and show found computer's EAs
	ExtensionAttributes=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/macaddress/$MAC/subset/extension_attributes -X GET)
	if [ $verbose = on ]
		then
			echo "VERBOSE: EA Info: "$ExtensionAttributes""
	fi	

	################################### DUMP LOCATION INFO ##########################################

	#####
	# Temporary XML file location
	LocationTempFile="/tmp/Location-XML-for-"$SOURCECOMPUTER".xml"

	######
	# Dumping gathered location information into an xml file.

	echo "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>
	<computer>
		<location>
			<username>"$Username"</username>
			<real_name>"$Realname"</real_name>
			<email_address>"$EmailAddress"</email_address>
			<position>"$Position"</position>
			<phone>"$Phone"</phone>
			<department>"$Department"</department>
			<building>"$Building"</building>
			<room>"$Room"</room>
		</location>
	</computer>" > $LocationTempFile

	################################### DUMP EA INFO ##########################################

	#####
	# Temporary XML file location
	EATempFile="/tmp/EA-XML-for-"$SOURCECOMPUTER".xml"

	######
	# Dumping gathered location information into an xml file.

	echo "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>
	<computer>
		<extension_attributes>" > $EATempFile

	#####
	# Grab a list of the id's of the EAs
	EA_IDs=$(echo $ExtensionAttributes | xpath '//computer/extension_attributes/extension_attribute/id' 2>&1 | awk -F'<id>|</id>' '{print $2}' | awk '/./')

	for id in $(echo "$EA_IDs")
		do
			EA_Type=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computerextensionattributes/id/$id -X GET | xpath '//computer_extension_attribute/input_type/type' 2>&1 | awk -F'<type>|</type>' '{print $2}' | awk '/./')
			if [[ "$EA_Type" == *script* ]]
				then
					if [ $verbose = on ]
						then
							echo "VERBOSE: ID $id is of type "$EA_Type" and will be skipped"
					fi	
				else
					if [ $verbose = on ]
						then
							echo "VERBOSE: ID $id is of type "$EA_Type" and will be included"
					fi	
					idvalue=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/macaddress/"$MAC"/subset/extension_attributes  | xpath "//extension_attribute[id="$id"]" 2>&1 | awk -F'<value>|</value>' '{print $2}' | awk '/./')
					if [ $verbose = on ]
						then
							echo "VERBOSE: Value of EA $id is "$idvalue""
					fi	
	echo "		<extension_attribute>
				<id>$id</id>
				<value>$idvalue</value>
			</extension_attribute>"	>> 	$EATempFile	
			fi
		done
	
		echo "	</extension_attributes>
	</computer>" >> $EATempFile


	################################### PUT XML FILES ##############################################

	if [ $NoPrompt = no ]
	then
		echo ""
		echo "The following items will be migrated from $CompID to $DestCompID:"
		echo ""
		echo "LOCATION INFORMATION"
		echo "Username: "$Username""
		echo "Real Name: "$Realname""
		echo "Email Address: "$EmailAddress""
		echo "Position: "$Position""
		echo "Phone Number: "$Phone""
		echo "Department: "$Department""
		echo "Building: "$Building""
		echo "Room: "$Room""
		echo ""
		echo "EXTENSION ATTRIBUTES:"
		EA_IDs=$(echo $ExtensionAttributes | xpath '//computer/extension_attributes/extension_attribute/id' 2>&1 | awk -F'<id>|</id>' '{print $2}' | awk '/./')
		for id in $(echo "$EA_IDs")
			do
				EA_Type=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computerextensionattributes/id/$id -X GET | xpath '//computer_extension_attribute/input_type/type' 2>&1 | awk -F'<type>|</type>' '{print $2}' | awk '/./')
				if [[ "$EA_Type" != *script* ]]
					then
						idvalue=$(curl -s -u "$APIUser":"$APIPass" "$CasperURL"/JSSResource/computers/macaddress/"$MAC"/subset/extension_attributes  | xpath "//extension_attribute[id="$id"]" 2>&1 | awk -F'<value>|</value>' '{print $2}' | awk '/./')
						echo "ID: 	$id"
						echo "Value:	$idvalue"
				fi
			done
		echo ""
		read -p "Proceed [ y | n ]? " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]
			then
				echo ""
				echo "$REPLY provided, proceeding..."
			else
				echo ""
				echo "$REPLY provided, exiting script..."
				rm $LocationTempFile
				rm $EATempFile
				exit 1
		fi
	fi

	if [ $verbose = on ]
		then
			echo "VERBOSE: Importing location information from $CompID to $DestCompID"
	fi	
	curl -s -u "$APIUser":$APIPass "$CasperURL"/JSSResource/computers/id/$DestCompID -X PUT -T $LocationTempFile &> /dev/null
	if [ $verbose = on ]
		then
			echo "VERBOSE: Importing Non-Scripted EA information from $CompID to $DestCompID"
	fi	
	curl -s -u "$APIUser":$APIPass "$CasperURL"/JSSResource/computers/id/$DestCompID -X PUT -T $EATempFile &> /dev/null

	################################### CLEAN UP ##############################################

	# Remove the temp files

	rm $LocationTempFile
	rm $EATempFile

	echo "Details migrated"

	counter=$(( $counter - 1 ))

done

exit 0

