/*
Cleaning Data in SQL Queries
*/


Select *
From ProjectPortfolio.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------
/*
-- Standardize Date Format


Select saleDate -- CONVERT(SaleDate, Date)
From ProjectPortfolio.NashvilleHousing;


Update NashvilleHousing
SET SaleDate = CONVERT(SaleDate, Date);

-- Another optoin to standardize date

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(SaleDate, Date)
;

*/
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From ProjectPortfolio.NashvilleHousing
Where length(PropertyAddress) > 0 
order by ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
From ProjectPortfolio.NashvilleHousing a
JOIN ProjectPortfolio.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
    Where length(a.PropertyAddress) > 0 ;


/*
Update ProjectPortfolio.NashvilleHousing
SET PropertyAddress = ifnull(PropertyAddress, PropertyAddress)
From ProjectPortfolio.NashvilleHousing a
JOIN ProjectPortfolio.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where length(PropertyAddress) = 0
;
*/


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From ProjectPortfolio.NashvilleHousing
-- Where length(PropertyAddress) = 0
-- order by ParcelID
;

SELECT
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, locate(',', PropertyAddress) + 1 , length(PropertyAddress)) as Address

From ProjectPortfolio.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress char(255);

SET SQL_SAFE_UPDATES = 0;

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity char(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, locate(',', PropertyAddress) + 1 , length(PropertyAddress))
;



Select *
From ProjectPortfolio.NashvilleHousing;





Select OwnerAddress
From ProjectPortfolio.NashvilleHousing;


Select
substring(OwnerAddress, 1, length(OwnerAddress) - length(substring_index(OwnerAddress, ',', -2))-1) ,
substring_index(substring_index(OwnerAddress, ',', -2), ',', 1) ,
substring_index(OwnerAddress, ' ', -1)
From ProjectPortfolio.NashvilleHousing;

  
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress char(255);

Update NashvilleHousing
SET OwnerSplitAddress = substring(OwnerAddress, 1, length(OwnerAddress) - length(substring_index(OwnerAddress, ',', -2))-1) ;


ALTER TABLE NashvilleHousing
Add OwnerSplitCity char(255);

Update NashvilleHousing
SET OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', -2), ',', 1) ;



ALTER TABLE NashvilleHousing
Add OwnerSplitState char(255);

Update NashvilleHousing
SET OwnerSplitState = substring_index(OwnerAddress, ' ', -1);



Select *
From ProjectPortfolio.NashvilleHousing;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectPortfolio.NashvilleHousing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From ProjectPortfolio.NashvilleHousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

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

From ProjectPortfolio.NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

;

Select *
From ProjectPortfolio.NashvilleHousing;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From ProjectPortfolio.NashvilleHousing;


ALTER TABLE ProjectPortfolio.NashvilleHousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;


