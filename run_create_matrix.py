import networkx as nx
# from networkx.readwrite.gexf import read_gexf,write_gexf
from networkx.readwrite import json_graph
import pandas as pd
from Cheetah.Template import Template

import simplejson as json

import os

def show_hashtags_as_list(key,network,dirname):
  # info,progress,view_type='experiment'):
  # print 'Creating list %s' % progress['view_number']
  # companies =
  # for node in network.nodes(data=True):
  #   print node
  # def visualize(title,categories,steps,templatefile,outfile):
  template = open('template/hashtaglist.tpl','r').read()
  values = {
    'title'     : 'Companies',
    'info'      : 'Just testing',
    'network'   : network,
    # 'progress'  : progress,
    # 'nameseed'  : progress['view_number'],
    # 'next_view' : 'view%s.html' % (progress['view_number']+1),
    # 'forward'   : forward,
    # 'time' : DEFAULT_TIME,
    'view_type' : 'list'
  }
  page = Template(template,searchList=[values])
  filename = 'view-hashtaglist.html'
  with open('%s/%s' % (dirname,filename),'wb') as f:
    f.write(str(page))
  return {'datakey': key, 'filename': filename, 'type': 'list'}

def show_tweeters_as_list(key,network,dirname):
  # info,progress,view_type='experiment'):
  # print 'Creating list %s' % progress['view_number']
  # companies =
  # for node in network.nodes(data=True):
  #   print node
  # def visualize(title,categories,steps,templatefile,outfile):
  template = open('template/tweeterlist.tpl','r').read()
  values = {
    'title'     : 'Companies',
    'info'      : 'Just testing',
    'network'   : network,
    # 'progress'  : progress,
    # 'nameseed'  : progress['view_number'],
    # 'next_view' : 'view%s.html' % (progress['view_number']+1),
    # 'forward'   : forward,
    # 'time' : DEFAULT_TIME,
    'view_type' : 'list'
  }
  page = Template(template,searchList=[values])
  filename = 'view-tweeterlist.html'
  with open('%s/%s' % (dirname,filename),'wb') as f:
    f.write(str(page))
  return {'datakey': key, 'filename': filename, 'type': 'list'}

def show_as_matrix(key,network,dirname):
  template = open('template/matrix.tpl','r').read()
  values = {
    'title'     : 'Companies',
    'info'      : 'Just testing',
    # 'datakey'   : key,
    'network'   : network,
    # 'progress'  : progress,
    # 'nameseed'  : progress['view_number'],
    # 'next_view' : 'view%s.html' % (progress['view_number']+1),
    # 'forward'   : forward,
    # 'time' : DEFAULT_TIME,
    'view_type' : 'matrix'
  }
  page = Template(template,searchList=[values])
  filename = 'view-matrix.html'
  with open('%s/%s' % (dirname, filename),'w') as f:
    f.write(str(page))
  return {'datakey':key,'filename':filename,'type':'matrix'}


def deploy_matrix(hashtag_network,outdir):
  degrees = nx.algorithms.centrality.degree_centrality(hashtag_network)
  eigenvectors = nx.algorithms.centrality.eigenvector_centrality(hashtag_network)
  for node_id in hashtag_network.nodes():
    hashtag_network.node[node_id]['degree'] = degrees[node_id]
    hashtag_network.node[node_id]['eigenvector'] = eigenvectors[node_id]

  # Getting only the top 100 nodes according to their betweenness centrality
  df_nodes = pd.DataFrame([data for node_id,data in hashtag_network.nodes(data=True)]).sort_values('eigenvector',ascending=False)
  print(df_nodes.head(10))
  top_nodes = df_nodes[:80].node_id.tolist()

  print('Total communities in top nodes: %s' % len(df_nodes[:80]['Modularity Class'].unique()))
  print('...according to degree: %s' % len(df_nodes.sort_values('degree',ascending=False)[:80]['Modularity Class'].unique()))
  print('...according to eigenvector: %s' % len(df_nodes.sort_values('eigenvector',ascending=False)[:80]['Modularity Class'].unique()))

  top_100_graph = nx.Graph()
  for edge in hashtag_network.edges(top_nodes,data=True):
    if edge[0] in top_nodes and edge[1] in top_nodes:
      # print edge
      weight = 1
      if 'weight' in edge[2]:
        weight = edge[2]['weight']
      top_100_graph.add_edge(edge[0],edge[1],weight=weight)
  for node_id,data in top_100_graph.nodes(data=True):
    top_100_graph.node[node_id]['partition'] = hashtag_network.node[node_id]['Modularity Class']
    top_100_graph.node[node_id]['degree'] = degrees[node_id]
    # top_100_graph.node[node_id]['volume'] = hashtag_network.node[node_id]['volume']
    for key in hashtag_network.node[node_id].keys():
      top_100_graph.node[node_id][key] = hashtag_network.node[node_id][key]
  # d = nx.readwrite.json_graph.node_link_data(top_100_graph)

  d = json_graph.node_link_data(top_100_graph) # node-link format to serialize

  with open(os.path.join(outdir,'network-one-mode.json'),'w') as f:
    json.dump(d,f,indent=1)

  show_as_matrix('network-one-mode',hashtag_network,outdir)

hashtag_network = nx.readwrite.gexf.read_gexf('data/01-network/hashtag-cooccurence-giant-component-with-modules.gexf',version='1.2draft')
deploy_matrix(hashtag_network,'visualize/02-hashtag-matrix')

# hashtag_network = nx.readwrite.gexf.read_gexf('data/08-hashtag-matrix/hashtag-cooccurence-with-modules.gexf',version='1.2draft')
# deploy_matrix(hashtag_network,'visualize/02-hashtag-matrix-filtered')

# show_hashtags_as_list('network-one-mode',hashtag_network,'out/05-view')
# show_tweeters_as_list('network-one-mode',tweeter_network,'out/05-view')
