/*
Data cleaning in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--1) Standardize data format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate= CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)	

--2)Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--3) Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
--CHARINDEX(',',PropertyAddress)

From PortfolioProject.dbo.NashvilleHousing

--create 2 new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))	


Select *
FROM PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

--PARSENAME

Select PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

--add 3 Columns and values

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)	

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)	

Select *
From PortfolioProject.dbo.NashvilleHousing

--4) Change Y to Yes, N to No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
				   When SoldAsVacant = 'N' Then 'No'
				   ELSE SoldAsVacant
				   END

Select *
From PortfolioProject.dbo.NashvilleHousing

-- 5) Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,	
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress


-- 6) Remove Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate