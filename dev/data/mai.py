sum=474.80
with open("plstate") as file:
    b=[((i.strip()).split("\t\t")) for i in file.readlines()]
b.pop(5)
for i in b[1:]:
    sum=sum+float(i[1])
    print(sum)