#!/bin/bash

DBHOST=127.0.0.1
BACKUPDIR="/var/backups/mongodb"
MAILCONTENT="log"
MAXATTSIZE="4000"
DOWEEKLY=6
DATE=`date +%Y-%m-%d-%Hh-%Mm`
DOW=`date +%A`
DNOW=`date +%u`
DOM=`date +%d`
M=`date +%B`
W=`date +%V`
VER=0.1
LOGFILE=$BACKUPDIR/$DBHOST-`date +%N`.log
LOGERR=$BACKUPDIR/ERRORS_$DBHOST-`date +%N`.log
BACKUPFILES=""
OPT=""

# Do we need to use a username/password?
#if [ "$USERNAME" ]
#  then
#  OPT="$OPT --username=$USERNAME --password=$PASSWORD"
#fi

# Create required directories
if [ ! -e "$BACKUPDIR" ]                # Check Backup Directory exists.
        then
        mkdir -p "$BACKUPDIR"
fi

if [ ! -e "$BACKUPDIR/daily" ]          # Check Daily Directory exists.
        then
        mkdir -p "$BACKUPDIR/daily"
fi

if [ ! -e "$BACKUPDIR/weekly" ]         # Check Weekly Directory exists.
        then
        mkdir -p "$BACKUPDIR/weekly"
fi

if [ ! -e "$BACKUPDIR/monthly" ]        # Check Monthly Directory exists.
        then
        mkdir -p "$BACKUPDIR/monthly"
fi

# IO redirection for logging.
touch $LOGFILE
exec 6>&1
exec > $LOGFILE
touch $LOGERR
exec 7>&2
exec 2> $LOGERR


# Database dump function
dbdump () {
mongodump --host=$DBHOST --out=$1 $OPT
return 0
}

# Run command before we begin
if [ "$PREBACKUP" ]
        then
        echo ======================================================================
        echo "Prebackup command output."
        echo
        eval $PREBACKUP
        echo
        echo ======================================================================
        echo
fi

# Hostname for LOG information
if [ "$DBHOST" = "localhost" ]; then
        HOST=`hostname`
        if [ "$SOCKET" ]; then
                OPT="$OPT --socket=$SOCKET"
        fi
else
        HOST=$DBHOST
fi

echo ======================================================================
echo AutoMongoBackup VER $VER
echo
echo Backup of Database Server - $HOST
echo ======================================================================

echo Backup Start `date`
echo ======================================================================
        # Monthly Full Backup of all Databases
        if [ $DOM = "01" ]; then
                echo Monthly Full Backup
                  dbdump "$BACKUPDIR/monthly/$DATE"
                echo ----------------------------------------------------------------------
        fi

        # Weekly Backup
        if [ $DNOW = $DOWEEKLY ]; then
                echo Weekly Backup
                echo
                echo Rotating 5 weeks Backups...
                echo
                        dbdump "$BACKUPDIR/weekly/week.$DATE"
                echo ----------------------------------------------------------------------
                tar -zcf "$BACKUPDIR/weekly/week.$DATE.tgz"  "$BACKUPDIR/weekly/week.$DATE"
        rm -rf "$BACKUPDIR/weekly/week.$DATE"
            find "$BACKUPDIR/weekly/" -mtime +2 -exec /bin/rm -f {} \;
        # Daily Backup
        else
                echo Daily Backup of Databases
                echo
                echo Rotating last weeks Backup...
                #eval rm -fv "$BACKUPDIR/daily/*"
                echo
                        dbdump "$BACKUPDIR/daily/$DATE"
                echo ----------------------------------------------------------------------
        tar -zcf "$BACKUPDIR/daily/$DATE.tgz"  "$BACKUPDIR/daily/$DATE"
        rm -rf "$BACKUPDIR/daily/$DATE"
        find "$BACKUPDIR/daily/" -mtime +2 -exec /bin/rm -f {} \;
        fi
echo Backup End Time `date`
echo ======================================================================

echo Total disk space used for backup storage..
echo Size - Location
echo `du -hs "$BACKUPDIR"`
echo
echo ======================================================================

# Run command when we're done
if [ "$POSTBACKUP" ]
        then
        echo ======================================================================
        echo "Postbackup command output."
        echo
        eval $POSTBACKUP
        echo
        echo ======================================================================
fi

#Clean up IO redirection
exec 1>&6 6>&-
exec 1>&7 7>&-
        if [ "$MAILCONTENT" = "log" ]
then
        cat "$LOGFILE" | mail -s "Mongo Backup Log for $HOST - $DATE" $MAILADDR
        if [ -s "$LOGERR" ]
                then
                        cat "$LOGERR" | mail -s "ERRORS REPORTED: Mongo Backup error Log for $HOST - $DATE" $MAILADDR
        fi
else
        if [ -s "$LOGERR" ]
                then
                        cat "$LOGFILE"
                        echo
                        echo "###### WARNING ######"
                        echo "Errors reported during AutoMongoBackup execution.. Backup failed"
                        echo "Error log below.."
                        cat "$LOGERR"
        else
                cat "$LOGFILE"
        fi
fi

if [ -s "$LOGERR" ]
        then
                STATUS=1
        else
                STATUS=0
fi

eval rm -f "$LOGFILE"
eval rm -f "$LOGERR"

exit $STATUS
