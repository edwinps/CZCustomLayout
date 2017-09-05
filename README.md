CZCustomLayout
=============

**CZCustomLayout** is a subclass of [UICollectionViewFlowLayout].

This layout is inspired by [Pinterest], using [CHTCollectionViewWaterfallLayout]

![2 columns]![](doc/screen.png)


Features
--------
* Easy to use.
* Customizable.
* Support header and footer views.
* Custom column number for one sections.

Prerequisite
------------
* ARC
* Xcode 7.1+.
* iOS 9+

How to install
--------------
* [CocoaPods]  
  - Add `pod 'CZCustomLayout'` to your Podfile.

* Manual  
  - Copy `BaseCollectionViewLayout.swift` to your project.

How to Use
----------

#### Step 1
In order to conform to the BaseCollectionViewLayoutProtocol protocol you have to adopt it in your UIViewController.

#### Step 2
To conform to the CZeyboardObserverDelegate you have to implement the following functions:

```swift
func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
--option--
func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForHeaderInSection section: Int) -> CGFloat
func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForFooterInSection section: Int) -> CGFloat
func collectionViewCellBigger(_ indexPath: IndexPath) -> Bool

```

#### Step 3
To config the layout in the viewcontroller

```swift
//create the Layout
let layout = BaseCollectionViewLayout()
//config margin
layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
// The minimum spacing to use between rows.
layout.minimumInteritemSpacing = 10
// The minimum spacing to use between columns
layout.minimumLineSpacing = 10
// number of columns
layout.numberOfColumns = 2
// Add the layout to your collection view
self.collectionView.collectionViewLayout = layout
//add delegate
layout.delegate = self

```

Limitation
----------
* Only vertical scrolling is supported.
* No decoration view.
* Only one section


## License
CZCustomLayout is licensed under the MIT licence. See the [LICENSE](https://github.com/edwinps/CZCustomLayout/blob/master/LICENSE.md) for more details.