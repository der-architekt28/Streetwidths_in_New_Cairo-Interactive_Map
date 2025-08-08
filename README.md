# Streetwidths_in_New_Cairo-Interactive_Map

This project contains an interactive plot, which visualizes the minimum distances between opposite buildings along the streets of a suburb of New Cairo, Egypt.
Such information might be valuable for assessing fire hazard, planning urban development or identificate potential evacuation routes in case of disaster.
 
 --- Workflow ---
 
 1. Based on a shapefile containing all of the suburb's buildings, minimum distances were computed by calculating connections between the nearest points of each pair of polygons.
 2. For the respective lines, a centroid point was computed, marking approximately the middle of the dividing street.
 3. By obtaining the minimum distance between the centroid point, whereat the resulting lines are clipped with the street area, a rough depiction of the road geometry is drawn.
 4. This roadmap was further enhanced by constructing buffers around the lines and intersecting the buffers with the non-building-area. 
 5. Lastly, Voronoi-polygons were drawn around each line centroid point and intersected with the previously calculated buffers.
 
 Note: This workflow was executed in QGIS. The individual steps to reproduce the result are attached in form of Python code lines ("preprocessing_python.txt") as well as JSON commands ("preprocessing_json.txt").
 
 
 --- Explanation regarding the plot ---
 
 - The interactive HTML-graph allows the user to explore and analyse the space between rows of houses, illustrated by Voronoi polygons.
 - Each of the coloured shapes doesn't show the average, but instead the minimum distance occurring within the polygon area.
 - By hovering over the objects, the value indicating the distance is shown as number laying in a defined interval, as explained by the legend. 
 - Furthermore, hovering with the cursor highlights every polygon containing a value of the same interval, showing similarly narrow street lines. 
