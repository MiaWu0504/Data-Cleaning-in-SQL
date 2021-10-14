--In this project we clean raw housing data and make it easier to work with future analysis in SQL Server

--Cleaning date in SQL

--------------------------------------------------------------------------------

select *
from PortfolioProject..NashvilleHousing

--Standardising date-time format

select SaleDate, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table PortfolioProject..NashvilleHousing
add SaleDateUpdated Date

update PortfolioProject..NashvilleHousing
set SaleDateUpdated = CONVERT(date, SaleDate)

select SaleDateUpdated
from PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------

--Populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------

--Breaking out address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


alter table PortfolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


select *
from PortfolioProject..NashvilleHousing


select OwnerAddress
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null


alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


alter table PortfolioProject..NashvilleHousing
add OwnerSplitState Nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



select *
from PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" field


select distinct SoldAsVacant, Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
       Case when SoldAsVacant = 'Y' then 'Yes'
	        when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end
from PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing
set  SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	        when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------

--Remove Duplicates

With temp as (
select *,
      ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)

DELETE
from temp
where row_num > 1


With temp as (
select *,
      ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)

select *
from temp
where row_num > 1

---------------------------------------------------------------------------------

--Delete Unused Columns


select *
from PortfolioProject..NashvilleHousing


Alter table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
