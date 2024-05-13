-- CLEANING DATA 
select * from [dbo].[NashvilleHousing]
--Standardize date format 

select SaleDate--, convert(date,SaleDate)
from [dbo].[NashvilleHousing]

update [dbo].[NashvilleHousing]
set SaleDate= convert(date,SaleDate)  -- done but not an inplace query , so must add column and update value   

ALTER Table [dbo].[NashvilleHousing]
add SaleDateConverted date

update [dbo].[NashvilleHousing]
set SaleDateConverted =convert(date,SaleDate)

-- populate Property Address
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)  -- automated populate w corresponding value
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b 
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set [PropertyAddress]= isnull(a.PropertyAddress,b.PropertyAddress)
-- set from given condition :
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b 
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- BREAKING OUT THE ADDRESS COLUMN
SELECT 
SUBSTRING([PropertyAddress],1, charindex(',',[PropertyAddress])-1) as Address,
substring ([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress])) as City
from [dbo].[NashvilleHousing]

alter table [dbo].[NashvilleHousing]
add City nvarchar(20)
add Address nvarchar(50),
update [dbo].[NashvilleHousing]
set Address = SUBSTRING([PropertyAddress],1, charindex(',',[PropertyAddress])-1),
City = substring ([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress]))
-- SPLITING BY PARSENAME - just work with '.'
select parsename(replace([OwnerAddress],',','.'),1) as StateOwner ,
parsename(replace([OwnerAddress],',','.'),2) as CityOwner,
parsename(replace([OwnerAddress],',','.'),3) As AddressOwner
FROM [dbo].[NashvilleHousing]
 

 alter table [dbo].[NashvilleHousing]
 add AddressOwner nvarchar(50),
 CityOwner nvarchar(50),
 StateOwner nvarchar(50)

 update [dbo].[NashvilleHousing]
 set AddressOwner =  parsename(replace([OwnerAddress],',','.'),3),
CityOwner=  parsename(replace([OwnerAddress],',','.'),2) ,
StateOwner= parsename(replace([OwnerAddress],',','.'),1) 


-- CHANGE Y AND N INTO YES AND NO IN  'SoldAsVacant'
select [SoldAsVacant],
case when [SoldAsVacant] ='Y' then 'Yes'
 when [SoldAsVacant] = 'N' then 'No'
 else [SoldAsVacant]
 end as fix
from[dbo].[NashvilleHousing]

update [dbo].[NashvilleHousing]
set [SoldAsVacant]=case when [SoldAsVacant] ='Y' then 'Yes'
 when [SoldAsVacant] = 'N' then 'No'
 else [SoldAsVacant]
 end 
 select distinct [SoldAsVacant] from [dbo].[NashvilleHousing]
 

 -- ROW_NUMBER  
 --If you’re building an application that displays employees in pages (e.g., 10 records per page), 
 --you can use ROW_NUMBER() for pagination. For the second page, 
 --you’d retrieve rows with row numbers from 11 to 20:
 SELECT *
FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY salary) AS row_num,
        first_name,
        last_name,
        salary
    FROM employees
) AS t
WHERE row_num > 10 AND row_num <= 20;
--Finding Nth Highest Value per Group: 
--Let’s say you want to find the employees with the highest salary in each department. 
--You can achieve this using ROW_NUMBER():
-- Find the highest salary per department
SELECT
    department_id,
    first_name,
    last_name,
    salary
FROM (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num,
        department_id,
        first_name,
        last_name,
        salary
    FROM employees
) AS t
WHERE row_num = 1;

-- REMOVE DUPLICATION
with ROWNUM as (
 SELECT *,
 ROW_NUMBER () OVER 
                (PARTITION BY[ParcelID],[PropertyAddress],[SaleDate],[SalePrice],[LegalReference]  -- PHÂN VÙNG THEO CÁC CỘT NÀY, GTRI ĐẦU TIÊN LÀ 1, GIÁ TRỊ DUP LÀ 2 
				order by UniqueID) as row_nums

from [dbo].[NashvilleHousing])
--order by ParcelID)

--DELETE     -- REMOVE DUP
--FROM ROWNUM WHERE  row_nums >1

select * 
from ROWNUM
WHERE row_nums >1
ORDER BY  [PropertyAddress]


-- REMOVE UNUSED COLUMNS 
ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN  [TaxDistrict]
SELECT * FROM [dbo].[NashvilleHousing]

