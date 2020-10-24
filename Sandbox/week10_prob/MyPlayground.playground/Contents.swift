import UIKit

var str = "Hello, playground"

let array1 = [1, 3, 3, 4]


func countOverlappedElement(arr: [Int])->Int{
    let size = arr.count
    var bag :[Int] = []
    var count :Int = 0
    for i in 0...size{
        for j in 0...bag.count{
            if(arr[i] == bag[j]){
                count += 1
            }else{
                bag.append(arr[i])
            }
        }
    }
    return count
}

print(countOverlappedElement(arr: array1))
