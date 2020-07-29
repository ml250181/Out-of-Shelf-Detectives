
import pandas as pd
import gensim
import logging
from gensim.models import Word2Vec
from nltk.tokenize import sent_tokenize, word_tokenize
import numpy as np
import operator

# import mpld3
import sys

import matplotlib.pyplot as plt
import seaborn as sns

sns.set_style("darkgrid")

from sklearn.decomposition import PCA
from sklearn.manifold import TSNE


def printList(lst):
    for line in lst:
        try:
            print(desc(line[0]), " - ", line[1])
        except:
            print(line[0], " - ", line[1])


def printListSimple(lst):
    for line in lst:
        try:
            print(desc(line), " - ", line)
        except:
            print(line, " - ", line)


def printListToFile(ItemId,lst, fileForPrint):
    for line in lst:
        try:
            print(ItemId ,"," , line[0], ",",line[1], file=fileForPrint)
        except:
            missingDescription = missingDescription + 1


def mostSimilar(model):
    print()
    w1 = input("Please input item id: ")
    print()
    try:
        print("----Your item", desc(w1), "-----")
    except:
        print("----Your item", w1, "-----")
    print()
    mostSimilar = model.wv.most_similar(positive=w1)
    printList(mostSimilar)


def desc(w1):
    w1 = w1.replace(",", "")
    try:
        if pd.isnull(itemsWithDescription[w1]):
            missingDescription = missingDescription + 1
            return w1
        return itemsWithDescription[w1]
    except:
        return w1


# dfitems =  pd.read_csv("C:\\Dev\\Innovation\\CustomerSegmentation\\Data\\\Items\ItemsDict.csv")
# itemsDic = dfitems.set_index('ProductId').to_dict()['Description']

# dfitems = pd.read_csv("C:\\Dev\\Innovation\\CustomerSegmentation\\Data\\\Items\AllItemsWithoutDuplicate.csv")
# itemsWithHierarchy = dfitems.set_index('ItemId').to_dict()['FinancialHierarchy']

dfitemsDesc = pd.read_csv("C:\\AI_MODEL\\Hacaton\\Data\\Dim_Items.csv")
itemsWithDescription = dfitemsDesc.set_index("ItemId").to_dict()["ItemName"]

# dfitemsOccurences =  pd.read_csv("C:\\Dev\\Innovation\\CustomerSegmentation\\Data\\\Items\ItemsOccurences_80.csv")
# itemsOccurencesDic = dfitemsOccurences.set_index('ItemId').to_dict()['Occurences']

model = Word2Vec.load("C:\\AI_MODEL\\Hacaton\\Data\\model26.model")
missingDescription = 0
 

f = open('C:\\AI_MODEL\\Hacaton\\Data\\itemsOUT26.txt', 'w') 
 

filepath = 'C:\\AI_MODEL\\Hacaton\\Data\\Items23.txt'

with open(filepath) as fp:
   line = fp.readline()
   
   while line:
       print("Line  : {}".format(  line.strip()))
      
       ItemId =format( line.strip())
       try:
           mostSimilar = model.wv.most_similar(positive=ItemId)
           printList(mostSimilar)
         #   f.write(','.join(printList(mostSimilar)) )
          #  f.write('mmmm' )  
           printListToFile(ItemId,mostSimilar, f)
       except:
           print("item not found  : {}".format(  line.strip()))

       line = fp.readline()

f.close()

  