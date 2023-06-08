inventories=read.csv("inventories.csv")
inventory_parts=read.csv("inventory_parts.csv")
inventory_minifigs=read.csv("inventory_minifigs.csv")
inventory_sets=read.csv("inventory_sets.csv")
inventory_sets=read.csv("inventory_sets.csv")
parts=read.csv("parts.csv")
colors=read.csv("colors.csv")
minifigs=read.csv("minifigs.csv")
sets=read.csv("sets.csv")
part_categories=read.csv("part_categories.csv")
part_relationships=read.csv("part_relationships.csv")
elements=read.csv("elements.csv")
themes=read.csv("themes.csv")

library(dplyr)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(r2r)
library(Polychrome)
library(stringr)

set.seed(23)

part_usage <- inventory_parts %>%
  group_by(part_num) %>%
  summarize(usage = sum(quantity)) %>%
  top_n(10)

part_usage <- merge(part_usage, parts, by="part_num")
part_usage <- merge(part_usage, part_categories, by.x="part_cat_id", by.y="id")
names(part_usage)[4] <- "part_name"
names(part_usage)[6] = "category_name"

p1 <- ggplot(part_usage, 
             aes(x=usage, y=reorder(part_name, usage), fill=category_name)) +
  geom_bar(stat="identity") +
  labs(title="Usage of top 10 most popular parts", x = "Usage", y="Part name", fill="Category name") +
  scale_fill_brewer(palette="Set1") +
  scale_y_discrete(labels = function(y) str_wrap(y, width=15)) +
  theme_minimal()
p1


colors_for_inventory <- inventory_parts %>%
  group_by(inventory_id) %>%
  summarize(num_of_colors = n_distinct(color_id)) %>%
  top_n(10)

colors_for_inventory <- merge(colors_for_inventory, inventories, by.x="inventory_id", by.y="id")
colors_for_inventory <- merge(colors_for_inventory, sets, by="set_num")
colors_for_inventory <- merge(colors_for_inventory, themes, by.x="theme_id", by.y="id")
names(colors_for_inventory)[6] <- "set_name"
names(colors_for_inventory)[10] = "theme_name"
colors_for_inventory$set_name <- paste(colors_for_inventory$set_name, "V", colors_for_inventory$version)

p2 <- ggplot(colors_for_inventory, 
             aes(x=num_of_colors,
                 y=reorder(set_name, num_of_colors), 
                 fill=theme_name,
                 label=img_url)) +
  geom_bar(stat="identity") +
  labs(title="Number of distinc colors for sets", x = "Number of distinc colors", y="Set name and version", fill="Theme") +
  scale_fill_brewer(palette="Set1") +
  theme_minimal()

p2 <- ggplotly(
  p2,
  tooltip = c('label'))

onRender(
  p2,
  "function(el,x){
    el.on('plotly_click', function(d) {
        if(d.points[0].text == undefined) {
          var websitelink = d.points[0].data.text.split('img_url:')[1];
        } else {
          var websitelink = d.points[0].text.split('img_url:')[1];
        }
        window.open(websitelink);
      });
    }")


alternates = hashtab()
for (x in parts$part_num) {
  alternates[[x]] = 0
}

alternative_relationships <- part_relationships %>%
  filter(rel_type == 'A')

for(i in c(1:length(alternative_relationships$rel_type))) {
  alternates[[alternative_relationships$child_part_num[i]]] = alternates[[alternative_relationships$child_part_num[i]]] + 1
  alternates[[alternative_relationships$parent_part_num[i]]] = alternates[[alternative_relationships$parent_part_num[i]]] + 1
}

parts_alternates <- parts

for(i in c(1:length(parts_alternates$part_num))) {
  parts_alternates$alternates[i] <- alternates[[parts_alternates$part_num[i]]]
}

part_usage <- inventory_parts %>%
  group_by(part_num) %>%
  summarize(usage = sum(quantity))

parts_alternates <- merge(parts_alternates, part_usage, by="part_num")

p3 <- ggplot(data=parts_alternates, 
     aes(
      x=usage, 
      y=alternates,
      color=part_material)) +
    geom_point(position=position_jitter(width = 0.1, height=0.1)) +
    scale_fill_brewer(palette="Set1") +
    labs(title="Alternate and usage of parts", x = "Usage of part", y="How many parts can alternate given part", color="Part material") +
    theme_minimal()
p3

popularity_of_themes <- sets %>%
  filter(year>=2008) %>%
  group_by(year, theme_id) %>%
  count() %>%
  rename(quantity=n) %>%
  arrange(desc(quantity)) %>%
  group_by(year) %>%
  slice(1:3) %>%
  mutate(rank=ceiling(rank(quantity)),
         position=4-((3-n())+rank))

popularity_of_themes$group_id = 0

for(i in c(1:length(popularity_of_themes$theme_id))) {
  if(any(popularity_of_themes %>% filter(year == popularity_of_themes$year[i]-1 | year == popularity_of_themes$year[i]+1) %>% pull(theme_id) == popularity_of_themes$theme_id[i])) {
    popularity_of_themes$group_id[i] = popularity_of_themes$theme_id[i]
  } else {
    rand = sample.int(999999, 1)
    while(any(popularity_of_themes$group_id == rand)) {
      rand = sample.int(999999, 1)
    }
    popularity_of_themes$group_id[i] = rand
  }
}

popularity_of_themes = merge(popularity_of_themes, themes, by.x="theme_id", by.y="id")
own_palette <- createPalette(length(unique(popularity_of_themes$name)),  c("#ff0000", "#00ff00", "#0000ff"))
names(own_palette) <- NULL

p4 <- ggplot(data=popularity_of_themes, 
             aes(
               x=year,
               y=position)) +
            geom_point(aes(color=factor(name))) +
            geom_line(aes(group=group_id, color=factor(name))) +
            scale_y_reverse() +
            scale_x_continuous(breaks = seq(2008, 2023, 3)) +
            scale_color_manual(values=own_palette) +
            labs(title="Rank of theme's popularity between 2008 and 2023", x = "Year", y="Rank", color="Theme") +
            theme_minimal()
p4


df = sets 
df$decade = df$year - df$year%%10
df$decade = as.factor(df$decade)
p5 = ggplot(df, 
            aes(x = decade, y = num_parts, fill = decade)) +
  geom_boxplot(outlier.shape = NA, show.legend = F) +
  labs(title="Variability of number of parts among decades ", x="Decade", y="Number of parts") +
  coord_cartesian(ylim = c(0, 300)) + 
  theme_minimal()
p5



df = sets 
df$decade = df$year - df$year%%10
df$decade = as.factor(df$decade)

quantile(df$num_parts, probs = c(0.25,0.5,0.75,0.9,0.95))

df = df %>% 
  group_by(decade) %>%
  summarize(
    q25 = quantile(num_parts, 0.25),
    q50 = quantile(num_parts, 0.5),
    q75 = quantile(num_parts, 0.75),
    q90 = quantile(num_parts, 0.9),
    q95 = quantile(num_parts, 0.95)
  )


p6 = ggplot(df, aes(x=decade)) +
  geom_area(aes(x = seq_along(q25), y = q25, fill = "25th percentile"), alpha = 0.1) +
  geom_line(aes(x = seq_along(q25), y = q25, color = "25th percentile"), size = 1) +
  geom_area(aes(x = seq_along(q50), y = q50, fill = "50th percentile"), alpha = 0.1) +
  geom_line(aes(x = seq_along(q50), y = q50, color = "50th percentile"), size = 1) +
  geom_area(aes(x = seq_along(q75), y = q75, fill = "75th percentile"), alpha = 0.1) +
  geom_line(aes(x = seq_along(q75), y = q75, color = "75th percentile"), size = 1) +
  geom_area(aes(x = seq_along(q90), y = q90, fill = "90th percentile"), alpha = 0.1) +
  geom_line(aes(x = seq_along(q90), y = q90, color = "90th percentile"), size = 1) +
  geom_area(aes(x = seq_along(q95), y = q95, fill = "95th percentile"), alpha = 0.1) +
  geom_line(aes(x = seq_along(q95), y = q95, color = "95th percentile"), size = 1) +
  labs(x = "Decade", y = "Number of Parts", title = "Distribution of Number of Parts by Decade") +
  scale_fill_manual(values = c("25th percentile" = "blue", "50th percentile" = "orange", "75th percentile" = "green", "90th percentile" = "purple", "95th percentile" = "red")) +
  scale_color_manual(values = c("25th percentile" = "blue", "50th percentile" = "orange", "75th percentile" = "green", "90th percentile" = "purple", "95th percentile" = "red")) +
  scale_x_continuous(breaks = 1:9, labels = seq(1940, 2020, 10)) +
  theme_minimal()
p6
