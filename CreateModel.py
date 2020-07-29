import pandas as pd
import gensim
from gensim.models import Word2Vec


NUM_CLUSTERS = 300

sample = open("C:\\AI_MODEL\\Hacaton\\Data\\data26.csv", "r")
s = sample.read()

data = []
count = 0
for line in s.split("\n"):
    temp = []
    count = count + 1
    for j in line.split(","):
        word = j.replace("'", "").replace(" ", "").replace('"', "")
        # if (word not in temp):
        temp.append(word)

    if len(temp) > 1:
        data.append(temp)
#   if (count % 100000 == 0):
#       print(line)
#       print("count = ", count)
#       print(data)

print("count = ", count)
model = gensim.models.Word2Vec(data, min_count=1, size=300, window=15)


model.save("C:\\AI_MODEL\\Hacaton\\Data\\model26.model")
print("finished....")

