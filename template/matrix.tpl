<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
##if $forward and $progress['task_number'] < $progress['total_tasks']:

<title>Ecosystem Research Study</title>
<!-- 
  design/code by L Cherny very much borrowed from 
  Mike Bostock's Les Mis co-occurrence adjacency matrix example; 
  see blog post 
  http://blogger.ghostweather.com/2012/03/digging-into-networkx-and-d3.html 
-->
<style>

#set $width = '%spx' % (int((float(len($network.nodes()))/100)*1200) - 100)
##set $width = '1200px'
body {
  position: relative;
  font-family: "Arial Narrow", sans-serif;
  margin: 8px;
  margin-bottom: 4em;
}

#content {
  /*width: $width;*/
  width: 1200px;
  /*height: 1200px;*/
  margin-left: auto;
  margin-right: auto;
}

footer {
  font-size: small;
  margin-top: 8em;
}

aside {
  font-size: medium;
  position:absolute;
  width: 180px;
  left: 840px;
}

h2,h3,h4 {
font-family: "Arial Narrow", sans-serif;
margin-top: .5em;
margin-bottom: .2em;
color: gray;
}

.midnote {
margin-top: .25em;
font-size: small;
border-bottom: 1px #ccc;
}

.infotext {
  font-size: medium;
  padding-bottom: .2em;
  }

.infotext p {
margin-top: .5em;
margin-bottom: .5em;
}

sourcenote {
font-style: italic;
font-size: small;
}


body > p {
  line-height: 1em;
  width: 1200px;
}

.infotext {
  font-size: medium;
  padding-bottom: .2em;
  }

a {
  color: steelblue;
}

a:not(:hover) {
  text-decoration: none;
}

.background {
  fill: #eee;
}

line {
  stroke: #fff;
}

text {
  font: 10px sans-serif;
}

text.active {
  fill: red;
}

text:hover {
  fill: red;
  cursor: default; 
}

</style>
<script src="js/d3/d3.min.js"></script>
<link rel="stylesheet" type="text/css" href="css/usertest.css"/>

<!--
<h2>Sample with High Eigenvector Centrality</h2>
-->

<!--<aside style="margin-top:0px; padding-top: 0px; width: 100ex; align: right;">-->
<!--
<div class="infotext">
<h3>Data Set</h3>

</div>
-->
<!-- start Mixpanel --><script type="text/javascript">(function(e,b){if(!b.__SV){var a,f,i,g;window.mixpanel=b;a=e.createElement("script");a.type="text/javascript";a.async=!0;a.src=("https:"===e.location.protocol?"https:":"http:")+'//cdn.mxpnl.com/libs/mixpanel-2.2.min.js';f=e.getElementsByTagName("script")[0];f.parentNode.insertBefore(a,f);b._i=[];b.init=function(a,e,d){function f(b,h){var a=h.split(".");2==a.length&&(b=b[a[0]],h=a[1]);b[h]=function(){b.push([h].concat(Array.prototype.slice.call(arguments,0)))}}var c=b;"undefined"!==
typeof d?c=b[d]=[]:d="mixpanel";c.people=c.people||[];c.toString=function(b){var a="mixpanel";"mixpanel"!==d&&(a+="."+d);b||(a+=" (stub)");return a};c.people.toString=function(){return c.toString(1)+".people (stub)"};i="disable track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config people.set people.set_once people.increment people.append people.track_charge people.clear_charges people.delete_user".split(" ");for(g=0;g<i.length;g++)f(c,i[g]);
b._i.push([a,e,d])};b.__SV=1.2}})(document,window.mixpanel||[]);
mixpanel.init("8b395a21fd4c888985a4da6a289e7b51");</script><!-- end Mixpanel -->

</head>
<body class="$view_type">
<!--
<div id="test">
  <div id="menu">
    <a href="view-list.html">List</a> |
    <a href="view-matrix.html">Matrix</a> |
    <a href="network">Network</a>
  </div>
</div>
-->
<div id="content">
<div id="control">
<label>Order Hashtags (From Top Left) By:
<select id="order">
  <option value="order">Eigenvector</option>
  <!-- <option value="volume">Volume</option>-->
  <option value="partition">Partition</option>
  <option value="degree">Total No. of Co-occuring Hashtags</option>
</select></label>
</div>
<!--
<p class="midnote"> Cells are colored by partition joint membership. Grey cells indicate links between nodes that don't share a partition.</p>

<sourcenote>Based on Mike Bostock's <a href="http://bost.ocks.org/mike/miserables/">Les Mis Co-occurrence Matrix Example</a>. Built with <a href="http://mbostock.github.com/d3/">D3</a>
  by <a href="http://www.ghostweather.com/">Lynn Cherny</a> from NetworkX analysis with accompanying <a href="http://blogger.ghostweather.com/2012/03/digging-into-networkx-and-d3.html">talk slides and blog post.</a></sourcenote>
-->
<!--</aside>-->
<script>

mixpanel.track("View matrix", {});

var color = d3.scale.ordinal()
    .domain([0,1,2,3,4,5,6,7,8,9,10])
    .range(["Red", "Purple", "Orange","LimeGreen", "Magenta", "DarkGreen", "Blue", 
      "#CC99FF", "Brown", "HotPink", "Yellow"]);

#set $nodes = len($network.nodes())
#set $width = int((float($nodes)/100)*1200) - int((float($nodes)/100)*100)
#set $height = int((float($nodes)/100)*1200) - int((float($nodes)/100)*100)

#set $width = 1000
#set $height = 1000

var margin = {top: 100, right: 0, bottom: 10, left: 150},
    width = $width,
    height = $height;

var x = d3.scale.ordinal().rangeBands([0, width]),
    z = d3.scale.linear().domain([0, 4]).clamp(true),
    c = d3.scale.category10().domain(d3.range(10));

var svg = d3.select("#content").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    // .style("margin-left", -margin.left + 20 + "px")
    .style("margin-left", "0px")
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

#set $filename = 'network-one-mode.json' 

d3.json("$filename", function(json) {
  // var sorted = json.nodes.slice();
  // sorted.sort(function(a,b) {return d3.descending(a.degree,b.degree);});
  var matrix = [],
      // nodes = sorted.slice(0,100),
      // nodes = sorted,
      nodes = json.nodes,
      n = nodes.length,
    linkstotal = 0;
    
  // Compute index per node.
  nodes.forEach(function(node, i) {
    // console.log(i);
    // console.log(node);
    node.index = i;
    matrix[i] = d3.range(n).map(function(j) { return {x: j, y: i, z: 0, weight: 0}; });
  });

  // Convert links to matrix; count character occurrences.
  json.links.forEach(function(link) {
    // console.log(link);
    if ((link.source < n) && (link.target < n)) {
      // console.log(link.source+', '+link.target);
      matrix[link.source][link.target].z += Math.sqrt(link.weight);
      matrix[link.target][link.source].z += Math.sqrt(link.weight);
      matrix[link.target][link.source].weight += link.weight;
      matrix[link.source][link.target].weight += link.weight;
      // The following two lines create the diagonal       
      matrix[link.source][link.source].z += 1;
      matrix[link.target][link.target].z += 1;
      linkstotal += 1;
    }
  });
  // Precompute the orders.
  var orders = {
    order: d3.range(n).sort(function(a, b) { return nodes[b].eigenvector - nodes[a].eigenvector; }),
    degree: d3.range(n).sort(function(a, b) { return nodes[b].degree - nodes[a].degree; }),
    betweenness: d3.range(n).sort(function(a, b) { return nodes[b].betweenness - nodes[a].betweenness; }),
    volume: d3.range(n).sort(function(a, b) { return nodes[b].volume - nodes[a].volume; }),
    partition: d3.range(n).sort(function(a, b) { return nodes[b].partition - nodes[a].partition; })
    // trustworthiness: d3.range(n).sort(function(a, b) { return nodes[b].trustworthiness - nodes[a].trustworthiness; })
  };

  // The default sort order.
  x.domain(orders.order);

  svg.append("rect")
      .attr("class", "background")
      .attr("width", width)
      .attr("height", height);

  var row = svg.selectAll(".row")
      .data(matrix)
    .enter().append("g")
      .attr("class", "row")
      .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
      .each(row);

  row.append("line")
      .attr("x2", width);
    
  row.append("text")
      .attr("x", -6)
      .attr("y", x.rangeBand() / 2)
      .attr("dy", ".32em")
      .attr("text-anchor", "end")
      .text(function(d, i) { return nodes[i].label; });
      // .on('mouseover', mouseover_row)
      // .on('mouseout', mouseout_row);

  var column = svg.selectAll(".column")
      .data(matrix)
    .enter().append("g")
      .attr("class", "column")
      .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });

  column.append("line")
      .attr("x1", -width);

  column.append("text")
      .attr("x", 6)
      .attr("y", x.rangeBand() / 2)
      .attr("dy", ".32em")
      .attr("text-anchor", "start")
      .text(function(d, i) { return nodes[i].label; });
      // .on("mouseover", mouseover)
      // .on("mouseout", mouseout);

  row.append("title")
   .text(function(d, i) { return nodes[i].label + 
    '\nVolume: ' + nodes[i].volume +
    '\nTotal No. of Co-occuring Hastags: ' + nodes[i].weighed_degree +
    '\nPartition: ' + nodes[i].partition});

  column.append("title")
   .text(function(d, i) { return nodes[i].label + 
    '\nVolume: ' + nodes[i].volume +
    '\nTotal No. of Collaboration Partners: ' + nodes[i].degree +
    '\nPartition: ' + nodes[i].partition});

  function row(row) {
    var cell = d3.select(this).selectAll(".cell")
        .data(row.filter(function(d) { return d.z; }))
      .enter().append("rect")
        .attr("class", "cell")
        .attr("x", function(d) { return x(d.x); })
        .attr("width", x.rangeBand())
        .attr("height", x.rangeBand())
        .style("fill-opacity", function(d) { return z(d.z); })
        .style("fill", function(d) { return nodes[d.x].partition == nodes[d.y].partition ? get_color(nodes[d.x].partition) : null; })
        .on("mouseover", mouseover)
        .on("mouseout", mouseout);

    cell.append("title")
      .text(function(d, i) {
        if (d.x != d.y) {
          return 'Total of ' + d.weight + ' collaborations between '
            + nodes[d.y].label + ' and ' + nodes[d.x].label;
          }          
        });
  }

  function mouseover(p) {
    console.log('Mouseover: ' + p);
    d3.selectAll(".row text").classed("active", function(d, i) { return i == p.y; });
    d3.selectAll(".column text").classed("active", function(d, i) { return i == p.x; });
  }

  function mouseout() {
    d3.selectAll("text").classed("active", false);
  }

  function mouseover_row(p) {
    console.log('Mouseover_row: ' + p)
    d3.selectAll(".row text").classed("active", function(d, i) { 
      console.log(i);
      return i == p.y; });
    // d3.selectAll(".column text").classed("active", function(d, i) { return i == p.x; });
  }

  function mouseout_row() {
    d3.selectAll("text").classed("active", false);
  }

  d3.select("#order").on("change", function() {
    clearTimeout(timeout);
    order(this.value,true);
  });

  function order(value, user_initiated) {
    if (user_initiated) {
      mixpanel.track("Order matrix", {
        "order_criteria": value
      });
    }
    x.domain(orders[value]);

    var t = svg.transition().duration(2500);

    t.selectAll(".row")
        .delay(function(d, i) { return x(i) * 4; })
        .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
      .selectAll(".cell")
        .delay(function(d) { return x(d.x) * 4; })
        .attr("x", function(d) { return x(d.x); });

    t.selectAll(".column")
        .delay(function(d, i) { return x(i) * 4; })
        .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });
  }

  function get_color(partition) {
    // console.log(partition);
    return color(partition)
    // c(partition);
  }

  var timeout = setTimeout(function() {
    order("order");
    d3.select("#order").property("selectedIndex", 0).node().focus();
  }, 5000);
  
  var asidetextlengths = ["Nodes: " + nodes.length, "Edges: " + linkstotal];
   
  d3.select("aside div.infotext").selectAll("p")
  .data(asidetextlengths)
  .enter()
  .append("p")
  .text(function(d) {return d;});
  
});

</script>
</div>
<div id="footer">
  <p> 
    Tailored for CMADFI2014 by Jukka Huhtam&auml;ki (<a href="https://twitter.com/jnkka">@jnkka</a>). Based on <a href="http://blogger.ghostweather.com/2012/03/digging-into-networkx-and-d3.html">Lynn Cherny's design and code</a> that again is a version of 
    Mike Bostock's <a href="http://bost.ocks.org/mike/miserables/">Les Miserables co-occurrence</a> example. 
   </p>
</div>
</body>
</html>