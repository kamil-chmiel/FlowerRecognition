# Flower Recognition

Identifying the type of flower from the captured photo for iOS devices in Swift

![Project Image](https://i.imgur.com/ak6cdFv.jpg?1) ![Project Image](https://i.imgur.com/lAQVQde.jpg?1)

---

## Description
Flower Recognition App allows us to get information about the plant we are looking at in a simple way.
We use oxford102.caffemodel converted to FlowerClassifier.mlmodel using python script and coremltools. With converted model we are able to recognize the type of the flower from captured photo, get the information using Wikipedia API and show it to the user.

---

## How to use

If you want to build the app, you have to download oxford102.caffemodel, convert it to .mlmodel file using for example python script and add it to the main project folder.

Model has been exclude from the repository due to it's big size.

---

## Frameworks
- Alamofire
- SwiftyJSON
- SDWebImage
- SVProgressHUD
- CoreML
- Vision

Dependency Manager: Cocoapods

---

## Author Info

- LinkedIn - [Kamil Chmiel](https://www.linkedin.com/in/kamil-chmiel-597080156/)
