--Cleaning Data in SQL Queries

	--Advise: Don't DELETE or CHANGE anything from the raw data, do a copy before you start cleaning it in case some mistakes are made


--Getting familiar with the data
Select *
From PortfolioProjects.dbo.NashvilleHousing


--Change Datetime Format to Date Format

--1º Method (sometimes it doesn't work)
	Update PortfolioProjects.dbo.NashvilleHousing
	SET SaleDate = CONVERT(Date,SaleDate)

	--I used this to check if it worked
	Select SaleDate
	From PortfolioProjects.dbo.NashvilleHousing

--2º Method
	ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
	Add NewSaleDate Date

	Update PortfolioProjects.dbo.NashvilleHousing
	SET NewSaleDate = CONVERT(Date,SaleDate)

	--I used this to check if it worked
	Select NewSaleDate, SaleDate
	From PortfolioProjects.dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

--Look for null values in that column
Select *
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

--Looking at the data it easy to see there's a relation between address and parcel ID
Select *
From PortfolioProjects.dbo.NashvilleHousing
order by ParcelID

--Using that relation between the two we can populate the address column
--Query for properties with the same ParcelID but different UniqueID
--ISNULL checks the first parameter in the parentheses, if it's null it populates with the second parameter in the parenthesis
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Now that we know what we need we can update the table to populate the column
--Using: ISNULL(a.PropertyAddress,b.PropertyAddress)
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Check for null values in Adress to see if it worked
Select *
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing

--We can use the comma delimiter to separate the address 
--1º Substring
	--SUBSTRING(column name, position to start substring, position to end substring)
	--CHARINDEX(character or string we want the index of, column name)
	--We need to add -1 to CHARINDEX so the comma is not in the SUBSTRING output
--2º Substring
	--We can use CHARINDEX to tell when to start the substring
	--In this one we need to add 1 so the comma is not in the output
	--We use LEN(column name) to make the substring stop at the end
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProjects.dbo.NashvilleHousing

--We need to add a column for each substring we want to save in the table
--And use the substrings we looked for before as the new value to save
--1º Substring
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add NewPropertyAddress Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET NewPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--2º Substring
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add NewPropertyCity Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET NewPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Check to see if it worked out ok
Select NewPropertyAddress, NewPropertyCity, PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing

--We need to see how the address are saved
Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing

--An easier way to separate is using PARSENAME
--PARSENAME is useful for strings with a specific delimiter: "."
--We can use REPLACE to change the commas for periods
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects.dbo.NashvilleHousing

--Create the column and save the new substrings
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add NewOwnerAddress Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add NewOwnerCity Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add NewOwnerState Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--You can check if it worked with this query
Select NewOwnerAddress, NewOwnerCity, NewOwnerState
From PortfolioProjects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

--Look for the words used in that column
--There's Y, N, Yes and No
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--CASE can be used when you have different possibilities
--Use When then you start listing the outputs depending on the case that occurs
--The last one is ELSE and you close with END
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjects.dbo.NashvilleHousing

--Use UPDATE to change the values in that column
Update PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--We can check with this if the table is in fact updated
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

--ROW_NUMBER() OVER( PARTITION BY   ORDER BY  ))
--We need to PARTITION BY the group of columns that need to be the same to consider it a duplicate row
--ORDER BY a number that should be Unique, in this data they can have the same address but now UniqueID
--After the parentheses you include a name to use for the numbers generated with ROW_NUMBER
--You could also use RANK instead of ROW_NUMBER
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
From PortfolioProjects.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Using SELECT in the query above allows you to see the duplicates
--To delete those duplicates change SELECT for DELETE
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
From PortfolioProjects.dbo.NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 1

--Use the first query to look for duplicates and check if it worked

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

--We can use this method to drop the columns we previously separated or we don't need for analysis
--Look at your table and see what you want to delete
--In this case, OwnerAddress, PropertyAddress and SaleDate are columns we changed so the originals we don't need them anymore
--TaxDistrict is not useful for the analysis we want to make in this case
Select *
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
