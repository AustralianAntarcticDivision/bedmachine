# BedMachine Antarctica on source.coop

Product repository for [`ausantarctic/bedmachine`](https://source.coop/ausantarctic/bedmachine):
Cloud Optimized GeoTIFF copies of MEaSUREs BedMachine Antarctica (Morlighem,
NSIDC-0756), and the virtual multidimensional indexes over them.

NSIDC distributes each version as one netCDF file behind a NASA Earthdata
login, and withdraws a version when it is retired (Version 3 on
2026-02-24). The published COGs are copies that stay readable without a
login, and the indexes reference them.

## Published layout

```
bedmachine/
  README.md
  v4.1/cog/                       Version 4, file V04.1 (2026)
  virtual/                        STAC catalog and the indexes
  virtual/bedmachine-v4.1/        mdim.vrt, kerchunk/, icechunk/, flat/, stac/, store.sqlite
```

`v4.1/cog/` holds one COG per array of the netCDF (`bed`, `dataid`,
`errbed`, `firn`, `geoid`, `mask`, `rgi`, `source`, `surface`, `thickness`)
and a `provenance.json` with the checksum of the source file and of every
COG, and the result of a pixel comparison with the netCDF.

## Byte makers

Scripts that write the published bytes. `bedmachine_cog.py` needs GDAL
(Python bindings) and numpy; `fetch.sh` needs curl and an Earthdata login
token.

| script | writes | from |
|---|---|---|
| `bytes/fetch.sh` | `RAW/<file>.nc`, `RAW/fetch.tsv` (URL, size, SHA-256) | NSIDC Earthdata Cloud |
| `bytes/bedmachine_cog.py` | `v4.1/cog/<array>.tif`, `provenance.json` | the NSIDC netCDF, EPSG:3031 |

```sh
EDL_TOKEN=... bash bytes/fetch.sh RAW
python bytes/bedmachine_cog.py --nc RAW/NSIDC-0756_BedMachineAntarctica_19700101-20191001_V04.1.nc \
  --fetch RAW/fetch.tsv --out v4.1/cog
```

The COGs keep the values, type and nodata of the netCDF arrays, with ZSTD
level 17, no predictor (a predictor makes the Kerchunk and Icechunk forms
unreadable by GDAL's Zarr driver), 512 x 512 tiles, and AVERAGE overviews
(NEAREST for the class arrays). The published `v4.1/cog/` objects of
2026-11-25 were written by `bedmachine_cog.py` as it is here (the same file
as `py/bedmachine_cog.py` of raad.virtualize at `13f3a72`), with GDAL 3.13.3
in `ghcr.io/hypertidy/gdal-r-python-extras@sha256:77c40c7b...`, from the
netCDF of SHA-256
`6bd08dbbe1a781834450cd25f7b5f438463a540a873d819bb781912e7ecb1538`.

## State of the move

This repository is the BedMachine product repo of the per-product repo map
(product files, dataset config, byte makers and runner here; engine from
[raad.virtualize](https://github.com/mdsumner/raad.virtualize) at a tag).
The move is staged. Still in raad.virtualize, until it has a tag to pin:

| piece | path in raad.virtualize |
|---|---|
| product files | `products/bedmachine/` (`product.json`, `datasets.tsv`, `README.md`) |
| dataset config | `config/bedmachine.sh` |
| COG writer (copy of `bytes/bedmachine_cog.py`) | `py/bedmachine_cog.py` |
| runner | `hpc/vm/bedmachine-publish.sh` |
| build notes | `docs/bedmachine-source-coop.md` |

## Citation and terms

NSIDC states: "These data are freely, openly, and fully available to use
without restrictions, provided that you cite the data according to the
recommended citation at <https://nsidc.org/about/data-use-and-copyright>."

Morlighem, M. (2025). MEaSUREs BedMachine Antarctica (NSIDC-0756, Version
4). [Data set]. Boulder, Colorado USA. NASA National Snow and Ice Data
Center Distributed Active Archive Center.
<https://doi.org/10.5067/POJQI54A45HX>

Morlighem, M., Rignot, E., Binder, T., Blankenship, D. D., Drews, R.,
Eagles, G., et al. (2020). Deep glacial troughs and stabilizing ridges
unveiled beneath the margins of the Antarctic ice sheet. Nature Geoscience,
13, 132-137. <https://doi.org/10.1038/s41561-019-0510-8>
