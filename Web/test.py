import urllib.request

url = "http://localhost/amihan/index.php?action=batch_update&src_id=814173"
url1 = "http://localhost/amihan/index.php?action=query_sensor&src_id=814173";

res = urllib.request.urlopen(url).read()
res1 = urllib.request.urlopen(url1).read()

print(res)
print(res1)