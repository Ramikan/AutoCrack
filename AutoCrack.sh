#! /bin/bash
mytitle="Password Auditing"
clear
read -p "Running For First Time:(y/n)" install
if [ "$install" == y ]
then
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Installing required tools for the auditing"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
sudo apt-get install toilet figlet python3-impacket impacket-scripts hashcat pipal
sudo git clone https://github.com/clr2of8/DPAT.git
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Downloading huge wordlist for the cracking from weakpass.com"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
sudo wget https://download.weakpass.com/wordlists/1948/weakpass_3a.7z
sudo mv weakpass_3a.7z /usr/share/seclists/Passwords/Leaked-Databases/
fi
if [ "$install" == n ]
then
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Skipping tools installation"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
fi
clear
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Copy pentest.zip file into the folder from where you running this script"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
sleep 20
figlet -f big "AutoCrack"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Tool used for Automating Password Cracking & Auditing"
echo "Version (beta)"
echo By Ramikan
echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++
read -p "Enter The Client Name:" companyname
mkdir $companyname
unzip pentest.zip -d $companyname
mv pentest.zip $companyname
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
figlet -f big "STAGE: 1"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo  '\033k'Dumping Hashes'\033\\' 
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
#impacket-secretsdump target -target-ip $dcip -outputfile $companyname/$companyname -history
impacket-secretsdump -system $companyname/pentest/registry/SYSTEM -ntds "$companyname/pentest/Active Directory/ntds.dit" LOCAL -outputfile $companyname/$companyname -history
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
figlet -f big "STAGE: 2"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo '\033k'Cracking Hashes Using Wordlist Attack'\033\\'
hashcat -m 3000 -a 3 $companyname/$companyname.ntds -1 ?a ?1?1?1?1?1?1?1 --increment --potfile-path=$companyname/$companyname.pot
hashcat -m 1000 -a 0 $companyname/$companyname.ntds /usr/share/seclists/Passwords/* --session=$companyname --potfile-path=$companyname/$companyname.pot 
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
figlet -f big "STAGE: 3"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo '\033k'Cracking Hashes Using Wordlist+Rule Attack'\033\\'
hashcat -m 1000 -a 0 $companyname/$companyname.ntds /usr/share/seclists/Passwords/Leaked-Databases/weakpass_3a.7z -r /usr/share/hashcat/rules/* --session=$companyname --potfile-path=$companyname/$companyname.pot 
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
figlet -f big "STAGE: 4"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo  '\033k'Cracking Hashes Using Combination Attack'\033\\'
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
hashcat -m 1000 -a 1 $companyname/$companyname.ntds /usr/share/seclists/Passwords/Leaked-Databases/weakpass_3a.7z /usr/share/seclists/Passwords/Leaked-Databases/hashesorg2019.gz --session=$companyname --potfile-path=$companyname/$companyname.pot 
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
figlet -f big "STAGE: 5"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo  '\033k'Cracking Hashes Using Mask Attack'\033\\'
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo 'This will take long time, do you want to continue?, if not press 'q' or ctrl+c'
hashcat -m 1000 -a 3 $companyname/$companyname.ntds /usr/share/hashcat/masks/pathwell.hcmask --session=$companyname --potfile-path=$companyname/$companyname.pot 
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
figlet -f big "STAGE: 6"
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo  '\033k'Collecting Password Stats & Reporting'\033\\'
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
sudo DPAT/dpat.py -n $companyname/$companyname.ntds -c $companyname/$companyname.pot -d $companyname/ -o $companyname.html
sudo cat $companyname/$companyname.pot | cut -d ":" -f 2 >$companyname-password.out
sudo pipal companyname-password.txt >>Pipal-Report.out
sudo statsgen companyname-password.txt >>Statgen-Report.out
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
echo 'Report Generated @' $companyname/
echo +++++++++++++++++++++++++++++++++++++++++++++++++++
