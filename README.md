# autovars

PowerShell module for creating calculated variables in PowerShell

# QuickStart

    > # import the module into your session
	
    > import-module autovars

    > # define an automatic variable
    > new-autovariable -name now -getter { get-date }

    > # use the automatic variable
    > $now
    Wednesday, May 07, 2014 12:10:11 AM
    > $now
    Wednesday, May 07, 2014 12:10:14 AM


