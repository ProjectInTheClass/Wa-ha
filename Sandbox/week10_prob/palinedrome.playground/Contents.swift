import UIKit

var str = "Hello, playground"

let array1 = [1, 2, 2, 1]
let array2 = [1, 2, 3, 4, 3, 2, 1]
let array3 = [1, 3, 4, 4, 1]
let array4 = [1, 2, 3, 1]

// 배열의 순서를 반대로 바꿔도 같은 배열인지를 판별
func isPalindromeArray(arr: [Int])->Bool{
    let size = arr.count
    var isPalindrome = true
    
    for i in 1...size/2{
        if(arr[i] != arr[size - i - 1]){
            isPalindrome = false
        }
    }
    
    return isPalindrome
}

print(isPalindromeArray(arr: array4))



