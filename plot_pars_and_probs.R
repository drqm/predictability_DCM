working.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(working.dir)

library(ggplot2)
library(reshape2)
#library(geomnet)
library(cowplot)
## load results from model averages
p <- read.csv('results/data/BMA_parameters.csv',header=T,sep = ',')
p[,-1] <- round(p[,-1],3)
pmu <- melt(p,id.vars = 'parameter_name',measure.vars = colnames(p)[c(2,5,8,11)])
pvar <- melt(p,id.vars = 'parameter_name',measure.vars = colnames(p)[c(3,6,9,12)])
pprob <- melt(p,id.vars = 'parameter_name',measure.vars = colnames(p)[c(4,7,10,13)])
plong1 <- cbind(pmu,pvar[,-c(1,2)],pprob[,-c(1,2)])
plong1$inference_type <- 'model average'

## load results from greedy search
p <- read.csv('results/data/BMA_parameters_greedy.csv',header=T,sep = ',')
p[,-1] <- round(p[,-1],3)
pmu <- melt(p,id.vars = 'parameter_name',measure.vars = colnames(p)[c(2,5,8,11)])
pvar <- melt(p,id.vars = 'parameter_name',measure.vars = colnames(p)[c(3,6,9,12)])
pprob <- melt(p,id.vars = 'parameter_name',measure.vars = colnames(p)[c(4,7,10,13)])
plong2 <- cbind(pmu,pvar[,-c(1,2)],pprob[,-c(1,2)])
plong2$inference_type <- 'model reduction'

plong <- rbind(plong1,plong2)

## organize data

colnames(plong)[2:5] <- c('factor','mean','variance','probability')
plong$factor <- as.character(plong$factor)
plong$factor[plong$factor == 'entropy_mu'] <- 'predictability_mu'
plong$factor <- factor(gsub('_mu','',plong$factor),
                       levels = c('MMN','predictability','expertise','interaction'))
plong$parameter_name <- as.factor(gsub('_',' to ',plong$parameter_name))
plong$parameter_name2 <- factor(plong$parameter_name,
                               levels = levels(plong$parameter_name)[c(7,8,10,4,11,3,9,2,6,1,5)])
plong$parameter_name <- factor(plong$parameter_name,
                                levels = levels(plong$parameter_name)[c(5,1,6,2,9,3,11,4,10,8,7)])

plong$family <- NA
plong$family[plong$parameter_name %in% c('rA1 to rA1','lA1 to lA1','rSTG to rSTG','lSTG to lSTG')] <- 'intrinsic'
plong$family[plong$parameter_name %in% c('rA1 to rSTG','lA1 to lSTG')] <- 'forward'
plong$family[plong$parameter_name %in% c('rSTG to rA1','lSTG to lA1')] <- 'backward'
plong$family[plong$parameter_name %in% c('rFOP to rSTG','rSTG to rFOP','rFOP to rFOP')] <- 'opercular'
#plong$family[is.na(plong$family)] <- 'null'

plong$family <- factor(plong$family, levels = c('intrinsic','forward','backward','opercular'))

## Make a plot
bma_pars <- ggplot(plong,aes(x = parameter_name2,y = mean, color = family,shape = family)) + 
  geom_point(size = 3) + 
  geom_errorbar(aes(ymin=mean-sqrt(variance)*1.96,ymax=mean + sqrt(variance)*1.96),
                width=0, size = 1) + 
  geom_hline(yintercept = 0) +
  theme_bw() +
  ylab('change in connection strength') +
  xlab('connection')+
  facet_grid(inference_type~factor) +
  coord_flip() +
  theme(legend.position = 'bottom', axis.text = element_text(size = 7)) +
  labs(color = "Model family: ", shape = "Model family: ")

## Now plot family probabilities

p <- read.csv('results/data/family_comp.csv',header=T,sep = ',')

p$family <- as.factor(c('intrinsic','forward','backward','opercular'))
p$family <- factor(p$family,levels = c('intrinsic','forward','backward','opercular'))

plong3 <- melt(p,id.vars= c('family'))
colnames(plong3)[2:3] <- c('factor','probability')
plong3$family2 <- factor(p$family,levels = c('opercular','backward','forward','intrinsic'))
fam_prob <- ggplot(plong3,aes(family2,probability,fill = family)) +
  geom_bar(stat = "identity", color = 'black', alpha = 0.5,show.legend = F) +
  geom_text(aes(label = round(probability,2)),hjust = 1.1,vjust = 0.5, color = 'black', size  = 3) +
  facet_wrap(~factor,ncol = 4) +
  xlab('model family') +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 60, vjust = 0.5)) +
  coord_flip();fam_prob

## Plot probability of models after BMA

plong$probability2 <- plong$probability
plong$probability2[plong$probability2 == 0] <- NA

par_prob <- ggplot(plong[plong$inference_type == 'model reduction',],aes(parameter_name2,probability,fill = family)) +
  geom_bar(stat = "identity", color = 'black', alpha = 0.5,show.legend = T) +
  geom_text(aes(label = round(probability2,2)),hjust = 1.5, vjust = 0.5, color = 'black',size = 3) +
  facet_wrap(~factor,ncol = 4) +
  xlab('connection') +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 60, vjust = 0.5, size = 7),
        legend.position = 'bottom') +# +
  labs(fill = "Model family: ") +
  coord_flip();par_prob

#Put together:

#a_b <- plot_grid(bma_pars,fam_prob, ncol =1,labels = c('a)','b)')); a_b
#all <- plot_grid(a_b,fam_prob, ncol = 2, labels = c('','c)'),rel_widths = c(4,1));all
all <- plot_grid(bma_pars,fam_prob, par_prob, ncol = 1, align = 'v',
                 axis  = 'b',labels = c('a)','b)','c)'),rel_heights = c(2,0.8,1.2));all

ggsave('results/figures/pars_and_probs.png',plot=all, height = 270, width = 190,  units = 'mm', dpi = 300)

## plot network structure:
# 
# cmatrix = matrix(c(1,0,1,0,0,
#                    0,1,0,1,0,
#                    1,0,1,0,1,
#                    0,1,0,1,0,
#                    0,0,1,0,1),nrow = 5)
# 
# colnames(cmatrix) = rownames(cmatrix) = c('A','B','C','D','E')
# ffdata <- fortify(as.adjmat(cmatrix))
# colnames(ffdata)[1:2] <- c('from_id','to_id')
# #network <- graph_from_adjacency_matrix(cmatrix)
# #plot(network)
# 
# orh <- 0.3
# orv <- 0.15
# 
# hor <- 0.2
# ver <- 0.2
# #coords <- matrix(c(0.3,-0.2,-0.3,-0.2, 0.3,0.1,-0.3,0.1,0.3,0.3),nrow = 5)
# coords <- data.frame(rbind(c(orh+hor,orv),c(orh,orv),c(orh+hor,orv+ver),c(orh,orv+ver),c(orh+hor,orv+2*ver)))
# coords$nodes <- c('A','B','C','D','E')
# ffdata[,c('x','y')] <- unlist(lapply(ffdata$from, function(x) coords[coords$nodes == x, c('X1','X2')]))
# #ffdata[,c('xend','yend')] <- unlist(lapply(ffdata$to, function(x) coords[coords$nodes == x, c('X1','X2')]))
# #colnames(ffdata)[3] <- 'weight'
# network_data <- StatNet$compute_network(ffdata, layout.alg = NULL)
# # ffdata[,c('x','y')] <- ffdata[,c('xcoord','ycoord')]
# # full <- plot(network, layout = coords, vertex.color = 'lightblue', vertex.frame.size = 3,vertex.size = 60,
# #      vertex.label.color = 'black', edge.color = 'black', edge.curved = T,loop.angle = -4,
# #      edge.lty = 'dashed',edge.width = 2, vertex.label.cex = 1.3)
# 
# ggplot(ffdata,aes(from_id= from_id,to_id = to_id,x = x, y=y)) +
#   geom_net(layout.alg = NULL,directed = T)
