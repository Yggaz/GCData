## Read in the Subject ID Data
SubjTest<-read.table("UCI HAR Dataset/test/subject_test.txt",header=F,col.names=c("SubjectID"))
SubjTrain<-read.table("UCI HAR Dataset/train/subject_train.txt",header=F,col.names=c("SubjectID"))

## Read in the File Features with Column Names
AllFeatures<-read.table("UCI HAR Dataset/features.txt", header=F, as.is=T, col.names=c("MeasureID", "MeasureName"))

## Read the X Data assigning column names from the features file
XTest<-read.table("UCI HAR Dataset/test/X_test.txt",header=F, col.names=AllFeatures$MeasureName)
XTrain<-read.table("UCI HAR Dataset/train/X_train.txt",header=F, col.names=AllFeatures$MeasureName)

## Read in the Ydata
YTest<-read.table("UCI HAR Dataset/test/y_test.txt",header=F,col.names=c("ActivityID"))
YTrain<-read.table("UCI HAR Dataset/train/y_train.txt",header=F,col.names=c("ActivityID"))

## Subset the column names
JustMeanStd<- grep(".*mean\\(\\)|.*std\\(\\)", AllFeatures$MeasureName)

## Subset the X data on the subset features
XTest<-XTest[,JustMeanStd]
XTrain<-XTrain[,JustMeanStd]

## Append the activity and Subject IDs
XTest$ActivityID<-YTest$ActivityID
XTest$SubjectID<-SubjTest$SubjectID
XTrain$ActivityID<-YTrain$ActivityID
XTrain$SubjectID<-SubjTrain$SubjectID

## Merge the update X files
merged_data<-rbind(XTest, XTrain)
cnames<-colnames(merged_data)
cnames<-gsub("\\.+mean\\.+", cnames, replacement="-Mean")
cnames<-gsub("\\.+std\\.+",  cnames, replacement="-Std")
colnames(merged_data)<-cnames

## Add an activiy names column
act<-read.table("UCI HAR Dataset/activity_labels.txt", header=F, as.is=T, col.names=c("ActivityID", "ActivityName"))
act$ActivityName<-as.factor(act$ActivityName)
lab_data<-merge(merged_data,act)

#===============================================================================================

# Creates a tidy data set with the average of each variable for each activity and each subject. 

library(reshape2)

## melt the dataset
newcols=c("ActivityID", "ActivityName", "SubjectID")
measure_vars=setdiff(colnames(lab_data), newcols)
melted_data<-melt(lab_data, id=id_vars, measure.vars=measure_vars)

## result 
result<-dcast(melted_data, SubjectID + ActivityName~ variable, mean)

## Create the tidy data set and save it on to the named file
write.table(result,"UCI HAR Dataset/tidy_data.txt")