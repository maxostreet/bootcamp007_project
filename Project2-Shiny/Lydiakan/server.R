
tw <- readRDS("TWN_adm2.rds")

server = function(input,output){
  #statistic 
  hr_stat = reactive({
    tt = filter(hp, Year == input$year & City %in% input$city) %>%
    select(City, ends_with(input$category))
    ttname= names(tt) 
    tt= tt %>% dcast(as.formula(paste(ttname[1:2], collapse ='~')), value.var = ttname[3]  )
    return(tt)
  })
  
  output$stata = renderGvis({
    #debuguse print (hr_stat())
    g1 = gvisBarChart(hr_stat(), "City", names(hr_stat())[2:4], 
                       options = list(colors= "['#EE3B3B', '#0000EE','#66CD00']",
                                      legend="right",
                                      bar="{groupWidth:'90%'}",gvis.editor="Make a change?",
                                      width=700,height=400))
    g1
  })
################################################ motion  
 
  hpPop = reactive({
    hpPopdf = subset(newhppop, 
                      select = -c(Population))
    if(input$type == "perCap") {
      colume_to_divide = setdiff(names(hpPopdf),
                                        c("City","Year",
                                          "Gb_ratio",
                                          "Sb_ratio"))
      hpPopdf[,colume_to_divide] = sweep(hpPopdf[,colume_to_divide], 1, 
                                     newhppop$Population, "/")
    }
    hpPopdf
  })
  
  output$statb = renderGvis({
    g2 = gvisMotionChart(hpPop(), idvar= 'City', timevar="Year")
    
    g2
  
  })
###################################################### map

  mapdata = reactive({
    if (input$ratio=="Gb_ratio"){
      mpdf = filter(newhppop, Year == input$year2) %>%
        select(City, Value=Gb_ratio)
    }else if(input$ratio=="Sb_ratio"){
      mpdf = filter(newhppop, Year == input$year2) %>%
        select(City, Value=Sb_ratio)
    }

    # colnames(mpdf)[2]='Value'
    mpdf$ratio= (mpdf$Value-min(mpdf$Value))/(max(mpdf$Value)-min(mpdf$Value))
    # row.names(mpdf) = trans[mpdf$City, 'COUNTYNAME']
    mpdf
  })
  

 # observe({
 #    print(mapdata())
 #  })
  
 output$statc = renderLeaflet({
   x <- mapdata()$ratio
   print(mapdata()$City)
   print(tw$NAME_2)
   rnk <- c(10,11,12,3,13,14,4,15,1,2,16,17,5,18,19,6,7,8,20,9,21,22)
   x <- x[rnk]
   fillColor <- colorRampPalette(c('white', 'darkblue'))(length(x))[rank(x)]
   leaflet(data = tw) %>% addTiles() %>% setView(lng = 120.9605, lat = 23.6978, zoom = 7) %>%
     addPolygons(fillColor = fillColor, stroke = FALSE, fillOpacity = .6)
 })
 
  # output$statc = renderLeaflet({
  #   
  #   geojson <- readLines(geo.json.url, warn = FALSE) %>%
  #     paste(collapse = "\n") %>%
  #     fromJSON(simplifyVector = FALSE)
  #   
  #   geojson$style = list(
  #     weight = 1,
  #     color = "#444444",
  #     opacity = 1,
  #     fillOpacity = 0.8
  #   )
  #   #pal <- colorQuantile("Greens", data$ratio)
  #   pal <- colorNumeric(c("white","darkblue"), mapdata()$ratio)
  #   
  #   geojson$features <- lapply(geojson$features, function(feat) {
  #     feat$properties$style <- list(
  #       fillColor = pal(
  #         mapdata()[feat$properties$COUNTYNAME, 'ratio']
  #       )
  #     )
  #     feat
  #   })
  # 
  #   leaflet() %>% setView(lng = 121, lat = 23.5, zoom = 6) %>% 
  #     addTiles() %>% addGeoJSON(geojson, fillColor = T)
  # })
  

  
  
}