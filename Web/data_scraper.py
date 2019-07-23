import urllib.request

src_ids = [814173, 814176, 814180, 814241, 810768]

for id in src_ids:
    res = urllib.request.urlopen("http://localhost/Website/amihan/index.php?action=batch_update&src_id=" + str(id)).read()
    print(res)