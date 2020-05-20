#!/usr/bin/env python

import sys
from ete3 import NCBITaxa

# get NCBI taxonomu object
ncbi = NCBITaxa()


def process_oxes(cq,oxes):

	genera = {}
	genera["unknown"] = 0
	#genera["unresolved"] = 0

	family = {}
	family["unknown"] = 0

	order = {}
	order["unknown"] = 0

	tclass = {}
	tclass["unknown"] = 0

	phylum = {}
	phylum["unknown"] = 0

	kingdom = {}
	kingdom["unknown"] = 0	

	for ox in oxes:

		# what to do if the taxid is not found?
		# happens frequently if UniProt database
		# is out of date
		try:
			# get entire lineage from this tax id
			lineage = ncbi.get_lineage(ox)
		except ValueError:
			genera["unknown"]  += 1
			family["unknown"]  += 1
			order["unknown"]   += 1
			tclass["unknown"]  += 1
			phylum["unknown"]  += 1
			kingdom["unknown"] += 1
			continue

		# get all names for that lineage
		names = ncbi.get_taxid_translator(lineage)

		# default position for a taxid
		# is that taxonomy is unknown
		g = "unknown"
		f = "unknown"
		o = "unknown"
		c = "unknown"
		p = "unknown"
		k = "unknown"

		# change default based on data
		for l in lineage:
			rank = ncbi.get_rank([l])

			if rank[l] == 'genus':
				g = names[l]

			if rank[l] == 'family':
				f = names[l]

			if rank[l] == 'order':
				o = names[l]

			if rank[l] == "class":
				c = names[l]

			if rank[l] == "phylum":
				p = names[l]

			if rank[l] == "superkingdom":
				k = names[l]

		# store and count
		if g in genera.keys():
			genera[g] += 1
		else:
			genera[g] = 1

		if f in family.keys():
			family[f] += 1
		else:
			family[f] = 1
		
		if o in order.keys():
			order[o] += 1
		else:
			order[o] = 1

		if c in tclass.keys():
			tclass[c] += 1
		else:
			tclass[c] = 1

		if p in phylum.keys():
			phylum[p] += 1
		else:
			phylum[p] = 1

		if k in kingdom.keys():
			kingdom[k] += 1
		else:
			kingdom[k] = 1


	print("%s\t%s\t%s\t%s\t%s\t%s\t%s" % (cq,winner(kingdom),winner(phylum), winner(tclass), winner(order), winner(family), winner(genera)))


def winner(lst):

	sorted_lst = [(k, lst[k]) for k in sorted(lst, key=lst.get, reverse=True)]
	winner = []

	#print(sorted_lst)

	if len(sorted_lst)==1:
		winner = sorted_lst[0]
	elif sorted_lst[0][1] > sorted_lst[1][1]:
		winner = sorted_lst[0]
	else:
		#print(sorted_lst)
		winner = ("unresolved",1)

	return winner[0]


done = dict()

if len(sys.argv) == 1:
	print("Please provide a filename")
	sys.exit()

# open the file
input_file = open(sys.argv[1], mode="r")

# set impossible top score
top_score = -999

# set empty hit
current_qry = ""

# set empty out string
out_str = "";

# set empty arrray
oxes = []

# iterate over file
for row in input_file:

	# split on whitespace
	arr = row.rstrip('\n\r').split('\t')

	# deal with the 1st row problem
	if current_qry == "":
		current_qry = arr[0]

	if top_score == -999:
		top_score = arr[14]

	# if the query has changed....
	if arr[0] != current_qry:
		process_oxes(current_qry,oxes)
		#process_oxes(oxes)
		oxes = []
		out_str = ""
		current_qry = arr[0]
		top_score = arr[14]

	# otherwise....
	current_qry = arr[0]

	# if the score is at least as good
	# as the top score
	#if arr[14] >= top_score:
	prop = int(arr[6]) / int(arr[4])
	if float(arr[3]) >= 60.0 and prop >= 0.6:
		ox = arr[2].split('OX=')[1].split(' ')[0]
		oxes.append(ox)
	

