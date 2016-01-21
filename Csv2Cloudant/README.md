# Push and Parse CSV data to Cloudant


## How to use
* Edit: ACCOUNTNAME, USERNAME, PASSWORD and DATABASE in the Python script

* Make sure to do your own Parsing in the Iterations-Part

* Be sure your Database exists in Cloudant (or CouchDB) and your user has rights to write

* Open Terminal

* Change to the directory
```bash
      $ cd csv2Cloudant
```

* Run Python in Terminal
```bash
      $ python csv2Cloudant.py 'data/myData.csv'
```

* You will see the progress in the Terminal

## Tip
* In the code the delimiter for CSV files is set to comma separated, this can be changed by editing this line

```python
reader = csv.DictReader(f, skipinitialspace=True, quotechar='"', delimiter=',')
```

* You will of course need python to run this script
