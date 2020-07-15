## ---- echo=TRUE, message=FALSE------------------------------------------------
suppressPackageStartupMessages({
library(dplyr)
library(knitr)
library(ggplot2)
library(reshape2)
})

#SD <- read.csv(bzfile("repdata_data_StormData.csv.bz2"))
SD <- read.csv("out.csv")

dim(SD)


## table {

##   margin: auto;

##   border-top: 1px solid #666;

##   border-bottom: 1px solid #666;

## }

## table thead th { border-bottom: 1px solid #ddd; }

## th, td { padding: 5px; }

## thead, tfoot, tr:nth-child(even) { background: #eee; }


## ---- echo=TRUE---------------------------------------------------------------
source("csv_data_mapping.R")
SD$EVTYPE <- trimtolower(SD$EVTYPE)
SD$EVTYPE <- csvmapping(SD$EVTYPE, "evtype-replacements.csv")


## ---- echo=TRUE---------------------------------------------------------------
sdWithValidEvtype <- subset(SD, !is.na(SD$EVTYPE))


## ---- echo=TRUE---------------------------------------------------------------
sdWithValidEvtype$CROPDMGEXP <- trimtolower(sdWithValidEvtype$CROPDMGEXP)
sdWithValidEvtype$CROPDMGEXP <- csvmapping(sdWithValidEvtype$CROPDMGEXP, "cropdmgexp-replacements.csv")

sdWithValidEvtype$PROPDMGEXP <- trimtolower(sdWithValidEvtype$PROPDMGEXP)
sdWithValidEvtype$PROPDMGEXP <- csvmapping(sdWithValidEvtype$PROPDMGEXP, "propdmgexp-replacements.csv")


## ---- echo=TRUE---------------------------------------------------------------
sdWithValidEvtype$FATALITIES <- replaceNa(sdWithValidEvtype$FATALITIES, 0)
sdWithValidEvtype$INJURIES <- replaceNa(sdWithValidEvtype$INJURIES, 0)

sdWithValidEvtype$PROPDMGEXP <- replaceNa(sdWithValidEvtype$PROPDMGEXP, 0)
sdWithValidEvtype$PROPDMG <- replaceNa(sdWithValidEvtype$PROPDMG, 0)

sdWithValidEvtype$CROPDMGEXP <- replaceNa(sdWithValidEvtype$CROPDMGEXP, 0)
sdWithValidEvtype$CROPDMG <- replaceNa(sdWithValidEvtype$CROPDMG, 0)


## ---- echo=TRUE---------------------------------------------------------------

kable(caption = "Event Types", data.frame(
    Event.Type = sort(unique(sdWithValidEvtype$EVTYPE))))


## ---- echo=TRUE---------------------------------------------------------------
fatalitiesPerEvtype <- sdWithValidEvtype %>%
                       group_by(EVTYPE) %>%
                       summarise(fatalities = sum(FATALITIES), injuries = sum(INJURIES), .groups='keep') %>%
                       filter(fatalities >= 500 | injuries >= 1000) %>%
                       arrange(desc(fatalities), desc(injuries), EVTYPE)


## ---- echo=TRUE---------------------------------------------------------------
kable(caption = "Event Types with the most fatalities or injuries", col.names=c("Event Type", "Fatalities", "Injuries"), fatalitiesPerEvtype)


## ---- echo=TRUE---------------------------------------------------------------
melted <- melt(fatalitiesPerEvtype, id.vars = "EVTYPE")

ggplot(melted %>% filter(variable=="fatalities"), aes(EVTYPE, value)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggtitle("Total fatalities per event type")

ggplot(melted %>% filter(variable == "injuries"), aes(EVTYPE, value)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggtitle("Total injuries per event type")


## ---- echo=TRUE---------------------------------------------------------------
dmgPerEvtype <- sdWithValidEvtype %>%
                mutate(calcDmg = PROPDMG * (10 ** as.numeric(PROPDMGEXP)) + CROPDMG * (10 ** as.numeric(CROPDMGEXP))) %>%
                group_by(EVTYPE) %>%
                summarise(dmg = sum(calcDmg), .groups='keep') %>%
                filter(dmg >= 10000000000) %>%
                arrange(desc(dmg), EVTYPE)



## ---- echo=TRUE---------------------------------------------------------------
kable(dmgPerEvtype, caption = "Event Types with the most economic impact", format.args=list(big.mark = ","), col.names=c("Event Type", "Impact ($)"))


## ---- echo=TRUE---------------------------------------------------------------
sessionInfo()


