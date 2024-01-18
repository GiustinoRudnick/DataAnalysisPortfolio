SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format, Multiple Methods

SELECT SaleDate
, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




-- Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT houseA.ParcelID
, houseA.PropertyAddress
, houseB.ParcelID
, houseB.PropertyAddress
, ISNULL(houseA.PropertyAddress, houseB.PropertyAddress) AS FixedNullAddress
FROM PortfolioProject.dbo.NashvilleHousing houseA
JOIN PortfolioProject.dbo.NashvilleHousing houseB
	ON houseA.ParcelID = houseB.ParcelID
	AND houseA.UniqueID <> houseB.UniqueID
WHERE houseA.PropertyAddress IS NULL

UPDATE houseA
SET PropertyAddress = ISNULL(houseA.PropertyAddress, houseB.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing houseA
JOIN PortfolioProject.dbo.NashvilleHousing houseB
	ON houseA.ParcelID = houseB.ParcelID
	AND houseA.UniqueID <> houseB.UniqueID
WHERE houseA.PropertyAddress IS NULL





-- Breaking Out Address Into Individual Columns (Street, City, State)

-- Using Substrings

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Using Delimiters

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3) AS Address
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2) AS City
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1) AS State
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)



-- Change Y and N to Yes and No in "Sold As Vacant" Column

SELECT SoldAsVacant, COUNT(SoldAsVacant) AS CountOfSoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY CountOfSoldAsVacant

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
	CASE	
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

	

--

-- Remove Duplicates

WITH RowNumberCTE AS(
	SELECT *
	,	ROW_NUMBER() OVER (
		PARTITION BY	ParcelID
						, PropertyAddress
						, SalePrice
						, SaleDate
						, LegalReference
						ORDER BY
							UniqueID
							) AS RowNumber
	FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumberCTE
WHERE RowNumber > 1



-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress
, TaxDistrict
, PropertyAddress
, SaleDate