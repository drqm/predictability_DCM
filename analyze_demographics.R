working.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(working.dir)

library(ggplot2)
##---
## This scrpit takes participant information, makes a report
## And compares the two groups (Musicians and Nonmusicians)

## Load the data
MEG <- read.table('participants_info_anonymized_m_nm.csv',header = TRUE,sep = ';')
exclude <- c(3,9,11,14,27,28,30,31,40,41)
MEG <- MEG[!MEG$Participant %in% exclude,]

## Define variables
expertise = c('N','M')
datasets = list("MEG" = MEG)

## Arrange in a dataframe
dem <- data.frame()
count = 0
for(d in names(datasets)){
  for(exp in expertise){
    count = count + 1
    data.sub = datasets[[d]][grepl(exp,datasets[[d]]$Expertise),]
    dem[count,"Exp"] <- d
    dem[count,"Group"] <- exp
    # dem[count,"Age (range)"] <- paste(as.character(min(data.sub$Age)),'-',
    #                                   as.character(max(data.sub$Age)), sep = "")
    dem[count,"Age (mean)"] <- mean(data.sub$Age)
    dem[count,"Age (SD)"] <- sd(data.sub$Age)
    dem[count,"Female"] <- sum(grepl("F",data.sub$Sex))
    dem[count,"Male"] <- sum(grepl("M",data.sub$Sex))
    # dem[count,"GMSI (range)"] <- paste(as.character(min(data.sub$GoldMSI)),'-',
    #                                       as.character(max(data.sub$GoldMSI)), sep = "")
    dem[count,"GMSI (mean)"] <- mean(data.sub$GoldMSI)
    dem[count,"GMSI (SD)"] <- sd(data.sub$GoldMSI)
    
    if (grepl("MEG",d)){
      # dem[count,"MET Mel (range)"] <- paste(as.character(min(data.sub$MET.Melody)),'-',
      #                                          as.character(max(data.sub$MET.Melody)), sep = "")
      dem[count,"MET Mel (mean)"] <- mean(data.sub$MET.Melody)
      dem[count,"MET Mel (SD)"] <- sd(data.sub$MET.Melody)
      # dem[count,"MET Rhy (range)"] <- paste(as.character(min(data.sub$MET.Rhythm)),'-',
      #                                           as.character(max(data.sub$MET.Rhythm)), sep = "")
      dem[count,"MET Rhy (mean)"] <- mean(data.sub$MET.Rhythm)
      dem[count,"MET Rhy (SD)"] <- sd(data.sub$MET.Rhythm)
      # dem[count,"MET Total (range)"] <- paste(as.character(min(data.sub$MET.Total)),'-',
      #                                         as.character(max(data.sub$MET.Total)), sep = "")
      dem[count,"MET Total (mean)"] <- mean(data.sub$MET.Total)
      dem[count,"MET Total (SD)"] <- sd(data.sub$MET.Total)
    }else {
#      dem[count,"MET Mel (range)"] <- NA
      dem[count,"MET Mel (mean)"] <- NA
      dem[count,"MET Mel (SD)"] <- NA
#      dem[count,"MET Rhy (range)"] <- NA
      dem[count,"MET Rhy (mean)"] <- NA
      dem[count,"MET Rhy (SD)"] <- NA
 #     dem[count,"MET Total (range)"] <- NA
      dem[count,"MET Total (mean)"] <-NA
      dem[count,"MET Total (SD)"] <-NA
    }
  }
}

## Create and export a report file
dem.export <- dem
row.names(dem.export) <- c()
num.cols <- c("Age (mean)","Age (SD)",
  "GMSI (mean)","GMSI (SD)",
  "MET Mel (mean)", "MET Mel (SD)",
  "MET Rhy (mean)", "MET Rhy (SD)",
  "MET Total (mean)", "MET Total (SD)")

dem.export[,num.cols] <- round(dem.export[,num.cols],2)

write.csv(file ="demographics_table.csv",
          dem.export,row.names = FALSE)

### report instruments
inst_vec = MEG$GMSI_39[which(MEG$Expertise == 'M')]
tab = as.data.frame(table(inst_vec));
colnames(tab) <- c("instrument","count")
tab$percentage <- round(tab$count*100/sum(tab$count),2)
tab = tab[order(-tab$count),]
tab = tab[-which(tab$count== 0),]

write.csv(file ="instruments_table.csv",
          tab,row.names = FALSE)

### Test GoldMSI

t.test(GoldMSI~Expertise, data=MEG, paired = FALSE)

### Test MET

t.test(MET.Total~Expertise, data=MEG, paired = FALSE)


