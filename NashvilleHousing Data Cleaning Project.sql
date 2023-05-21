/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject2].[dbo].[Sheet1$]
  --CLEANING DATA IN SQL

    --Standardize the date format
  Select SaleDateConverted,Convert(Date,SaleDate)
  From PortfolioProject2.dbo.NashvilleHousing

  Update NashvilleHousing
  SET SaleDate = Convert(Date,SaleDate)

  Alter Table NashvilleHousing
  Add SaleDateConverted Date;
  
  Update NashvilleHousing
  SET SaleDateConverted = Convert(Date,SaleDate)



  --Populate property Address data
  Select *
  From PortfolioProject2.dbo.NashvilleHousing
  --Where PropertyAddress is null
  Order by parcelID

  Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress,
  ISNULL(a.propertyaddress, b.propertyAddress)
  From PortfolioProject2.dbo.NashvilleHousing a
  Join PortfolioProject2.dbo.NashvilleHousing b
   On a.ParcelID = b.parcelID
   And a.[uniqueID] <>b.[uniqueID]
Where a.propertyaddress is null

Update a
Set PropertyAddress =  ISNULL(a.propertyaddress, b.propertyAddress)
From PortfolioProject2.dbo.NashvilleHousing a
  Join PortfolioProject2.dbo.NashvilleHousing b
   On a.PArcelID = b.parcelID
   And a.[uniqueID] <>b.[uniqueID]
Where a.propertyaddress is null



  --breaking address down into indivicual columns (Address,City,State)
 Select PropertyAddress
  From PortfolioProject2.dbo.NashvilleHousing
  --Where PropertyAddress is null
 -- Order by parcelID

 Select 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))as Address

 FROM PortfolioProject2.dbo.NashvilleHousing
  
	--Need to create two new columns

	
  Alter Table NashvilleHousing
  Add PropertySplitAddress nvarchar(255);
  
  Update NashvilleHousing
  SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

  Alter Table NashvilleHousing
  Add PropertySplitCity nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) 
  
  Select *
  From PortfolioProject2..NashvilleHousing
  -- Owner Adress by ParseName easier method

  Select OwnerAddress
  From PortfolioProject2..NashvilleHousing

  Select ParseName(Replace(OwnerAddress, ',','.'), 3),
  ParseName(Replace(OwnerAddress, ',','.'), 2),
  ParseName(Replace(OwnerAddress, ',','.'), 1)
    From PortfolioProject2..NashvilleHousing

	Alter Table NashvilleHousing
  Add OwnerSplitAddress nvarchar(255);
  
  Update NashvilleHousing
  SET OwnerSplitAddress =  ParseName(Replace(OwnerAddress, ',','.'), 3)

  Alter Table NashvilleHousing
  Add OwnerySplitCity nvarchar(255);

  Update NashvilleHousing
  SET OwnerySplitCity = ParseName(Replace(OwnerAddress, ',','.'), 2)
  

  Alter Table NashvilleHousing
  Add OwnerSplitState nvarchar(255);
  
  Update NashvilleHousing
  SET OwnerSplitState =  ParseName(Replace(OwnerAddress, ',','.'), 1)

  Select*
  From PortfolioProject2..NashvilleHousing

  --Change Y and N in 'Sold as vacant' field

  select distinct(soldasVacant), count(soldasVacant)
  From PortfolioProject2..NashvilleHousing
  group by soldAsVacant
  Order by 2

  select soldAsVacant, 
  Case When soldAsVacant= 'Y' Then 'Yes'
		When soldAsVacant = 'N' Then 'No'
		Else soldasVacant
		End
From PortfolioProject2..NashvilleHousing

Update NashvilleHousing
Set SoldasVacant =  Case When soldAsVacant= 'Y' Then 'Yes'
		When soldAsVacant = 'N' Then 'No'
		Else soldasVacant
		End



  --Deleting duplicates

With row_numCTE AS(
Select *,
	Row_number() over (
	Partition BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By UniqueID
	) Row_num
From PortfolioProject2..NashvilleHousing
--Order by ParcelID
)
Select *
From Row_numCTE
Where row_num > 1
Order by PropertyAddress

--Delete unused Columns using only on cte, not raw data

  
  Select *
  From PortfolioProject2..NashvilleHousing

  Alter Table PortfolioProject2.dbo.nashvilleHousing
  drop column OwnerAddress, taxDistrict, PropertyAddress

  Alter Table PortfolioProject2.dbo.NashvilleHousing
  Drop Column SaleDate