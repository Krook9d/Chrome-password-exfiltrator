# Chrome passwords exfiltrator

![](https://zupimages.net/up/22/38/sfmh.png)

**Table of Contents**

[About The Project](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#about-the-project)

[Requierements](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#requierements)

[2 type of exfiltration](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#2-type-of-exfiltration)

[Configuration](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#configuration)

[.EXE convertion](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#exe-convertion-)

[Detection](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#detection)

[Testing](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#testing)

[False positive](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#false-positive)

[Flipper zero/Rubber Ducky](https://github.com/Krook9d/Chrome-password-exfiltrator/blob/main/README.md#flipper-zero-bad-usb-configuration)

# About

This is a Chrome Passwords grabber. When your victim clicks on the .exe, their chrome passwords and usernames are written on a file or sent by email.


Like other browsers Chrome has a built-in login password manager functionality which keeps track of the login secrets of all visited websites. Whenever a user logs in to any website, they will be prompted to save their credentials for later use and if the user chooses so, then the username and passwords will be stored in an internal  database.
So next time onwards, when they visit that same website, they will be automatically logged in using these stored credentials which saves hassle of entering the credentials every time.

Chrome stores all the sign-on secrets into the internal database file called 'Web data' in the current user profile folder. A newer version has moved the login passwords related database into a new file named 'Login Data'.
This database file is in SQLite format and contain number of tables storing different kind of data such as auto complete, search keyword, ie7logins etc. in addition to login secrets.
The logins table mainly contains the information about sign-on secrets such as website URL, username, password fields, etc. All theise information are stored in clear text except passwords which are encrypted.

Google Chrome encrypts passwords with the help of CryptProtectData function, built into Windows. Now while this can be a very secure function using a triple-DES algorithm and creating user-specific keys to encrypt the data, it can still be decrypted as long as you are logged into the same account as the user who encrypted it.

The CryptProtectData function has a twin, which does the opposite; CryptUnprotectData, which... Well, you guessed it, decrypts the data.
Obviously this is going to be very useful while trying to decrypt the stored passwords.

## Disclaimer

This project is for educational purposes only I do not take any responsibilities for the actions people use this for.


### Requierements

> - pip install pypiwin32
> - pip install pycryptodome

### 2 types of exfiltration

You can choose between two types of exfiltration : 

###### By email

If you want the result remotely and you don't have internet restriction, it can be a good way.

![](https://zupimages.net/up/22/39/fpqq.png)

###### By file

This way might be more adequate if you have restrictions with a proxy for emails sending and if you have physical access to the machine.
This version works well with rubber ducky or bash bunny or flipper zero.
The script will grab the passwords and write them to a file. Feel free to specify an output file and to add a command to clean the logs.

![Alt Text](https://media.giphy.com/media/KV89f6lkh0asIu9vZN/giphy.gif)

Youtube link : https://youtu.be/3LgiQ_YQL6w

### Configuration


###### By email

You have to change the following placeholders :

24-25 : enter the information taken from the supplier's website
28-30 : enter the information on your e-mail address
33 : enter the recipient's information
![](https://zupimages.net/up/22/38/ug6s.png)


###### By file

You can add code lines to specify an output file and add command to clean the log 



#### .EXE convertion :

To make our script compatible and masquerading, we will have to convert it to .exe,

For this we will need https://pypi.org/project/auto-py-to-exe/ 

Fill in all the parameters and use an icon to make the best possible camouflage of your executable,
I have reproduced the installation file of Windows Edge as an example.

![](https://zupimages.net/up/22/39/e8ep.png)
![](https://zupimages.net/up/22/39/6ul4.png) If windows defender says so then...



### Detection

We assume that your anti-virus doesn't detect the malware (Highly likely if it is windows defender). You can detect this type of exfiltration with several SPLUNK rules :


 	 index=yourindex  source="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" process="*notepad.exe*" AND process="*.txt*" | table _time host app process process_current_directory user

notepad.exe is the basic software built into Windows by default, so an attacker will use it in most cases to exfiltrate the data recovered by his attack.
This rule will allow you to detect exfiltration with notepad.exe when it is triggered with a different process than a normal user interface and called by the system.

![](https://zupimages.net/up/22/39/bwfj.png)

test.txt was made by a call of notepad with a PowerShell script and ChromeIDS by the script presented in this page.

###### Testing

You can test this alert with PowerShell and the following command : 

 	 New-Item C:\Users\Public\test.txt

###### False positive

In large computer networks, it is necessary to segment the area of this alert, in fact it is a better idea to target end-user PCs, employees or any machines where performing automatic file writing operations is not unusual in the work habits of the users.
You could face false positives if this alert is activated on a perimeter where patch deployment or other maintenance operations are common.

### Flipper zero / Rubber Ducky (bad usb configuration)


	 coming soon


### Patchlog

To do :

- Flipper zero / Rubber Ducky (bad usb configuration) 
- Design of mail template for exfiltration
- Design of file template for exfiltration
- Splunk rule for Email Version

Contact : krook9d@gmail.com
