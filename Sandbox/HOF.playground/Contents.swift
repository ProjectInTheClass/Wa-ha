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


// 3 :
// 4 :
// 5 :



