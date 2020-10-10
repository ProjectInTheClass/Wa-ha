import UIKit

//1 : 2차원 배열 1차원으로 만들고 nil을 없앤다음 배열의 합을 구한는 HOF 코드를 한줄로 구현하시오
let input : [[Int?]] = [[3,10,nil], [9, -1, nil, 2], [3,10,nil] , [4, -5, nil, 2]]
var ans : Int = 0
for i in input {
    for j in i {
        if let item = j {
            ans += item
        }
    }
}
print(ans)





//2 : 배열엣서 튜플의 두번째 데이터 타입을 Int에서 String으로 바꾸시오 . (단 한줄로)
let tupleArr : [(String,Int)] = [ ("A",0), ("B",1), ("C", 2), ("D", 3) ]
var ans2 : [(String,String)] = []
for item in tupleArr {
    ans2.append((item.0, String(item.1)))
}
print(ans2)


// 3 : 합구하기
let array11 = [1, 2, 2, 1]
var sum = 0
for item in array11 {
    sum += item
}
print(sum)


// 합구하기 답
func sumAll(result: Int, arg: Int) -> Int{
    return result + arg
}

let ret = array11.reduce(0, sumAll)

let ret2 = array11.reduce(0) {
   (result, array11) -> Int in return result + array11
}



// 4 :
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

// 5 : 배열에서 모음의 갯수를 Int 로 리턴
var characters = ["A","B","D","I","U","P","Q","E"]
var count = 0
for char in characters {
    if char == "A" {
        count += 1
    }else if char == "E" {
        count += 1
    }else if char == "I" {
        count += 1
    }else if char == "O" {
        count += 1
    }else if char == "U" {
        count += 1
    }
}
print(count)







