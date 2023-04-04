data = read.csv("tcell_perturbations.csv")
ideal <- data.frame(condition="ideal", progenitor=0.95, effector=0, terminal.exhausted=0, cycling=0.05, other=0, cell.count=50)
data <- rbind(data, ideal)

###############################################################################################

p1 <- ggplot(data,
             aes(x=progenitor,
                 y=cell.count,
                 color=
                   ifelse(
                     condition=='ideal', "Ideal",
                     ifelse(
                       condition=="Unperturbed", "Unperturbed", "Perturbed")))) +
  geom_point(position=position_jitter(width = 0.005, height=0.005)) + 
  scale_color_manual(values=c('red', '#7AA0EC', 'green')) +
  labs(x="Progenitor", y="Count", color="Condition")

data_filtered <- filter(data, cell.count <= 100)
p2 <- ggplot(data_filtered,
             aes(x=progenitor,
                 y=cell.count,
                 color=
                   ifelse(
                     condition=='ideal', "Ideal",
                     ifelse(
                       condition=="Unperturbed", "Unperturbed", "Perturbed")))) +
  geom_point(position=position_jitter(width = 0.005, height=0.005)) + 
  scale_color_manual(values=c('red', '#7AA0EC', 'green')) +
  labs(x="Progenitor", y="Count", color="Condition")
p2 <- p2 + geom_hline(yintercept = 20, linetype='dashed', color='red')

grid.arrange(p1, p2, ncol=2)

data <- filter(data, cell.count > 20)

###############################################################################################

ggplot(data,
       aes(x=progenitor,
           y=cycling,
           color=
             ifelse(
               condition=='ideal', "Ideal",
               ifelse(
                 condition=="Unperturbed", "Unperturbed", "Perturbed")))) +
  geom_point(position=position_jitter(width = 0.005, height=0.005)) + 
  scale_color_manual(values=c('red', '#7AA0EC', 'green')) +
  labs(x="Progenitor", y="Cycling", color="Condition")

###############################################################################################

ggplot(data,
       aes(x = rowSums(data[,c(3,4,6)]),
           y = reorder(condition, -rowSums(data[,c(3,4,6)])),
           fill = ifelse(condition=='Unperturbed', 'Unperturbed', 'Perturbed'))) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values=c('#7AA0EC', 'yellow')) +
  labs(x = "Sum of unnecessary states", y="Condition", fill="Condition") +
  theme(panel.background = element_blank())

###############################################################################################

data <- subset(data, condition != 'ideal')
ideal_vect = c(0.95, 0, 0, 0.05, 0)
probs = data[c(2:6)]

manhattan_distance <- function(row, value) {
  sum(abs(row - value))
}

manhattan_distances <- apply(probs, MARGIN = 1, FUN = manhattan_distance, value = ideal_vect)
how_close <- max(manhattan_distances) + 1 - manhattan_distances

df <- data.frame(data, manhattan_distances, how_close)
df$cell.count_log <- log10(df$cell.count)


p <- ggplot(df,
      aes(x=progenitor,
          y=cycling,
          color=cell.count_log,
          size=how_close)) +
  scale_color_gradient(low='yellow', high='#AF1919') +
  geom_point(position=position_jitter(width = 0.005, height=0.005)) +
  labs(x="Progenitor", 
       y="Cycling", 
       color="Logarithmized cell count", 
       size="How close Condition is to Ideal from 1 to 3",
       title="Perturbations of TCELLs comparison",
       tooltip = "") 
p

# We don't know why size legend disappeared :(
p <- ggplotly(p)
p$x$data[[1]]$text <- paste("Condition: ", df$condition, "<br>",
                            "Manhattan distance: ", round(df$manhattan_distances,2), "<br>",
                            "Cell count: ", df$cell.count)
p
