DBCC FREEPROCCACHE;
SET STATISTICS TIME, IO ON;
GO
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
UNION ALL
SELECT  TOP 1 *
FROM
	Production.Product 
	INNER JOIN Production.ProductProductPhoto	ON Production.ProductProductPhoto.ProductID  = Production.Product.ProductID
	INNER JOIN Production.ProductPhoto	ON production.ProductPhoto.ProductPhotoID = production.ProductPhoto.ProductPhotoID
	INNER JOIN Production.ProductInventory ON Production.ProductInventory.ProductID = Production.Product.ProductID
	INNER JOIN Production.Location ON  Production.Location.LocationID = Production.ProductInventory.LocationID
	INNER JOIN Production.WorkOrderRouting	ON Production.WorkOrderRouting.LocationID =  Production.Location.LocationID
	INNER JOIN Production.WorkOrder	ON Production.WorkOrder.WorkOrderID =  Production.WorkOrderRouting.WorkOrderID
	INNER JOIN Production.ScrapReason ON Production.ScrapReason.ScrapReasonID = Production.WorkOrder.ScrapReasonID
	INNER JOIN Sales.ShoppingCartItem ON Sales.ShoppingCartItem.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductSubcategory	ON Production.ProductSubcategory.ProductSubcategoryID = production.Product.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ON Production.ProductCategory.ProductCategoryID = production.ProductSubcategory.ProductCategoryID
	INNER JOIN Production.ProductReview ON  Production.ProductReview.ProductID = Production.Product.ProductID
	INNER JOIN Production.ProductModel	ON Production.ProductModel.ProductModelID = Production.Product.ProductModelID
	INNER JOIN Production.ProductModelIllustration ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Illustration ON Production.Illustration.IllustrationID = Production.ProductModelIllustration.IllustrationID
	INNER JOIN Production.ProductModelProductDescriptionCulture ON Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
	INNER JOIN Production.Culture ON production.Culture.CultureID = Production.ProductModelProductDescriptionCulture.CultureID
WHERE Production.Product .ProductID = 1
