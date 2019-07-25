import urllib.request

src_ids = [814173, 814176, 814180, 814241, 810768]

for id in src_ids:
    url = "http://localhost/amihan/index.php?action=batch_update&src_id=" + str(id)
    res = urllib.request.urlopen(url).read()
    print("Connecting to: ", url)
    print(res)
    print()