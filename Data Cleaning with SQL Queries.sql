
/*
Cleaning Data with SQl Queries
*/






Select *
From portfolioproject..housingdata


-- Standardize Date Format 
  
  
 Select saleDateConverted, CONVERT(Date,SaleDate) 
 From PortfolioProject.dbo.housingdata
  
  
 Update housingdata
 SET SaleDate = CONVERT(Date,SaleDate) 
  
 -- If it doesn't Update properly 
  
 ALTER TABLE housingdata
 Add SaleDateConverted Date; 
  
 Update housingdata 
 SET SaleDateConverted = CONVERT(Date,SaleDate) 




 -- Populate Property Address data 
  
 Select * 
 From PortfolioProject.dbo.housingdata
 Where PropertyAddress is null 
 order by ParcelID 
  
  
  
 Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
 From PortfolioProject.dbo.housingdata a 
 JOIN PortfolioProject.dbo.housingdata b 
 	on a.ParcelID = b.ParcelID 
 	AND a.[UniqueID]  <> b.[UniqueID] 
 Where a.PropertyAddress is null 
  
  
 Update a 
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
 From PortfolioProject.dbo.housingdata a 
 JOIN PortfolioProject.dbo.housingdata b 
 	on a.ParcelID = b.ParcelID 
 	AND a.[UniqueID ] <> b.[UniqueID ] 
 Where a.PropertyAddress is null 


  
 -------------------------------------------------------------------------------------------------------------------------- 
  
 -- Breaking out Address into Individual Columns (Address, City, State) 
  
  
 Select PropertyAddress 
 From PortfolioProject.dbo.housingdata
 --Where PropertyAddress is null 
 --order by ParcelID 
  
 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address 
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address 
  
 From PortfolioProject.dbo.housingdata
  
  
 ALTER TABLE housingdata
 Add PropertySplitAddress Nvarchar(255); 
  
 Update housingdata 
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 
  
  
 ALTER TABLE housingdata
 Add PropertySplitCity Nvarchar(255); 
  
 Update housingdata
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 
  
  
  
  
 Select * 
 From PortfolioProject.dbo.housingdata 
  
  
  
  
  
 Select OwnerAddress 
 From PortfolioProject.dbo.housingdata
  
  
 Select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
 From PortfolioProject.dbo.housingdata
  
  
  
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
 From PortfolioProject.dbo.housingdata 


 -------------------------------------------------------------------------------------------------------------------------- 
  
  
 -- Change Y and N to Yes and No in "Sold as Vacant" field 
  
  
 Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
 From PortfolioProject.dbo.housingdata 
 Group by SoldAsVacant 
 order by 2 
  
  
  
  
 Select SoldAsVacant 
 , CASE When SoldAsVacant = 'Y' THEN 'Yes' 
 	   When SoldAsVacant = 'N' THEN 'No' 
 	   ELSE SoldAsVacant 
 	   END 
 From PortfolioProject.dbo.housingdata  
  
 Update housingdata 
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes' 
 	   When SoldAsVacant = 'N' THEN 'No' 
 	   ELSE SoldAsVacant 
 	   END 



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
  
 From PortfolioProject.dbo.housingdata 
 --order by ParcelID 
 ) 
 SELECT *
 From RowNumCTE 
 Where row_num > 1 
 Order by PropertyAddress 
  
  
  
 Select * 
 From PortfolioProject.dbo.housingdata


 --------------------------------------------------------------------------------------------------------- 
  
 -- Delete Unused Columns 
  
  
  
 Select * 
 From PortfolioProject.dbo.housingdata
  
  
 ALTER TABLE PortfolioProject.dbo.housingdata
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 
