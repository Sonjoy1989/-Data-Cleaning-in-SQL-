/*
Cleaning Data in SQL Queries
*/

Select *
From portfolioProject1..housingdata

-- Standardize Date Format

Select SaleDate , CONVERT(Date,SaleDate) as Newdata
From portfolioProject1..housingdata


Update housingdata
SET SaleDate = CONVERT(Date,SaleDate) 

 --If it doesn't Update properly
 ALTER TABLE housingdata
Add SaleDateConverted Date;

Update housingdata
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --Standardize Date Format After alter table

Select saleDateConverted, CONVERT(Date,SaleDate)
From portfolioProject1..housingdata

Update housingdata
SET SaleDate = CONVERT(Date,SaleDate)

 -- Populate Property Address data

 Select *
From portfolioProject1..housingdata
--Where PropertyAddress is NULL
order by ParcelID


 Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolioProject1..housingdata a
Join portfolioProject1..housingdata b
on a.ParcelID=b.ParcelID
AND a.[UniqueID] <>b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolioProject1..housingdata a
Join portfolioProject1..housingdata b
on a.ParcelID=b.ParcelID
AND a.[UniqueID] <>b.[UniqueID ]


---------------------------------------------------------------------
------ Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From portfolioProject1..housingdata
--Where PropertyAddress is NULL
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From portfolioProject1..housingdata

ALTER TABLE housingdata
Add PropertySplitAddress Nvarchar(255);

Update housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE housingdata
Add PropertySplitCity Nvarchar(255);

Update housingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From portfolioProject1..housingdata

------ Breaking out Address USING PARSENAME function into Individual Columns (Address, City, State)

Select OwnerAddress
From portfolioProject1..housingdata

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

From portfolioProject1..housingdata

ALTER TABLE housingdata
Add OwnerSplitAddress Nvarchar(255);

Update housingdata
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE housingdata
Add OwnerSplitCity Nvarchar(255);

Update housingdata
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE housingdata
Add OwnerSplitState Nvarchar(255);

Update housingdata
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From portfolioProject1..housingdata


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From portfolioProject1..housingdata
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant='Y' THEN 'YES'
       When SoldAsVacant='N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From portfolioProject1..housingdata

Update housingdata
SET SoldAsVacant= CASE When SoldAsVacant='Y' THEN 'YES'
       When SoldAsVacant='N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From portfolioProject1..housingdata
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From portfolioProject1..housingdata


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From portfolioProject1..housingdata

ALTER TABLE portfolioProject1..housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


