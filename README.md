# ldp-alignment

## Instructions for Downloading Data
We use [dat](https://datproject.org/) to host our data. In order to download data used, follow these instructions.

First, install dat:
```{bash}
npm install -g dat
```

Next, clone this repository and navigate to the `data/` folder.
```{bash}
git clone https://github.com/callab/ldp-alignment.git
cd data/
```

Finally, use dat to download the data using the address contained within the `.json` file. This step requires a P2P connection, so ensure another machine is syncing to the same dat address.  
```{bash}
dat clone dat.json
```