//  ContentView.swift
//  ImmersiveCalculator

// TODO: Here are todos
// 3-1. TODO: Tapping equal repeatedly, operating calculation repeatedly
// 3-2. "12+3===..." should become "12+3=15", then "15+3=18", "18+3=21" ...

// 4. TODO: Divide and multiply should be calculated first.

// 5. TODO: Not only AC but also just C is needed.
// 6. TODO: If undefined operation(i.e. divided by 0) is attempted, "Undefined" should be displayed.


import SwiftUI
import RealityKit
import RealityKitContent


enum CalcButton: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case add = "+"
    case subtract = "-"
    case divide = "÷"
    case multiply = "×"
    case equal = "="
    case clear = "AC"
    case decimal = "."
    case percent = "%"
    case negative = "+/-"
    
    var buttonColor: Color {
        switch self {
        case .add, .subtract, .divide, .multiply, .equal:
            return Color.basicOperator
        case .clear, .negative, .percent:
            return Color.command
        default:
            return Color.number
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .add, .subtract, .divide, .multiply, .equal:
            return 38
        case .negative, .percent:
            return 26
        case .clear:
            return 24
        default:
            return 30
        }
    }
    
    var operation: Operation {
        switch self {
        case .add:
            return .addOp
        case .subtract:
            return .subtractOp
        case .divide:
            return .divideOp
        case .multiply:
            return .multiplyOp
        default:
            return .none
        }
    }
    
}


enum Operation {
    case addOp, subtractOp, divideOp, multiplyOp, none
}


struct ContentView : View {
    
    @State var value = "0"
    @State var runningNumber:Decimal = 0
    // Variable for what the running operation is
    @State var currentOperation: Operation = .none
    // Variable for changing basic operator button color
    @State var activeButton: CalcButton?
    // Boolean for check if an operator is selected
    @State var isCalculating: Bool = false
    // Boolean for that number not follow the output number
    @State var isJustCalculated: Bool = false
    // Number input
    @State var inputNumbers: String = ""
    // Hold latest operand
    @State var latestOperand: Decimal = 0

    
    
    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]
    
    
    var body: some View {
        
        // View
        ZStack {
            // Background
            Color.background
            
            // Elements for the calculator
            VStack {
                
                // Text display
                HStack {
                    Spacer()
                    Text(addCommas(value))
                        .bold()
                        .font(.system(size:48))
                        .foregroundColor(.white)
                        .shadow(color: Color.shadowWhite, radius: 6, x: 0, y: 0)
                }
                .frame(width: 240, height: 50) // This frame prevend displayed number to be in 2 rows
                .padding()
                
                // Expression
                HStack {
                    Spacer()
                    Text(insertSpaces(inputNumbers))
                }
                .frame(width: 240, height: 20)
                
                // Buttons
                ForEach(buttons, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { item in
                            // Buttons excluding zero
                            if item != .zero {
                                Button(action: {
                                    // tapped event
                                    didTap(button: item)
                                }, label: {
                                    Text(item.rawValue)
                                        .frame(width: 50, height: 50)
                                        .font(.system(size: item.fontSize))
                                        .bold()
                                        .background(item == activeButton ? .white : item.buttonColor)
                                        .foregroundColor(item == activeButton ? .basicOperator : .white)
                                        .shadow(color: Color.shadowWhite, radius: 5, x: 0, y: 0)
                                        .clipShape(Circle())
                                })
                                .buttonStyle(PlainButtonStyle())
                                .hoverEffect(.lift)
                            }
                            // Zero button
                            else if item == .zero {
                                Button(action: {
                                    // tapped event
                                    didTap(button: item)
                                }, label: {
                                    Text(item.rawValue)
                                        .frame(width: 115, height: 50)
                                        .font(.system(size: item.fontSize))
                                        .bold()
                                        .background(item.buttonColor)
                                        .foregroundColor(.white)
                                        .shadow(color: Color.shadowWhite, radius: 5, x: 0, y: 0)
                                        .cornerRadius(50)
                                })
                                .buttonStyle(PlainButtonStyle())
                                .hoverEffect(.lift)
                            }
                        }
                    }
                }
                
            }
        }
        .frame(width: 280, height: 460)
        .cornerRadius(30)
    }
    
    
    
    
    // Funcions
    
    func didTap(button: CalcButton) {
        switch button {
        
        // In cases of operation buttons
        case .add, .subtract, .divide, .multiply, .equal:
    
            
            // Remove decimal point if any number follow the point
            if let lastCharacter = inputNumbers.last {
                if lastCharacter == "." {
                    // remove decimal point in expression
                    self.inputNumbers = String(inputNumbers.dropLast())
                    // remove decimal point in displayed value
                    self.value = String(value.dropLast())
                }
            }
            
            // In case of +, -, ÷, ×
            if button != .equal {
                
                
                /// inputNumbers
                // If expression contains "=" new expression starts
                if inputNumbers.contains("=") {
                    self.inputNumbers = self.value
                }
                // If last character is operator, remove the operator
                if let lastCharacter = inputNumbers.last {
                    if lastCharacter == "+" || lastCharacter == "-" || lastCharacter == "÷" || lastCharacter == "×" {
                        self.inputNumbers = String(inputNumbers.dropLast())
                    }
                }
                // Show operation input below the displayed number
                if self.value == "0" && self.inputNumbers == "" {
                    self.inputNumbers += self.value + button.rawValue
                } else {
                    self.inputNumbers += button.rawValue
                }
                
                
                // Change color of selected operator button
                self.activeButton = button
                
                
                // Run calculation with operators
                if currentOperation != .none && !isCalculating {
                    let currentValue = Decimal(string: self.value) ?? 0
                    let result = performOperation(self.currentOperation, on: self.runningNumber, and: currentValue)
                    self.value = formatNumber(result)
                }
                
                
                self.isCalculating = true
                
                // set operation
                self.currentOperation = button.operation
                
                // value becomes runningNumber
                self.runningNumber = Decimal(string: self.value) ?? 0
                
            } else if button == .equal {
                
                // If last character is an operator, repeat operation
                // i.e. "12+14+=" becomes "12+14+26=52"
                if let lastCharacter = inputNumbers.last {
                    if lastCharacter == "+" || lastCharacter == "-" || lastCharacter == "÷" || lastCharacter == "×" {
                        self.inputNumbers += self.value
                    }
                }
                
                let currentValue = Decimal(string: self.value) ?? 0
                let result = performOperation(self.currentOperation, on: self.runningNumber, and: currentValue)
                self.value = formatNumber(result)
                self.runningNumber = currentValue
                self.isCalculating = false
                self.isJustCalculated = true
                
                // reset operation
                self.currentOperation = .none
                
                // Show equal and result
                inputNumbers += button.rawValue + value
            }
            
            
        // Action for Clear button
        case .clear:
            // clear value
            self.runningNumber = 0
            self.value = "0"
            // set activeButton as none
            self.activeButton = nil
            // clear operation
            self.currentOperation = .none
            self.isCalculating = false
            self.isJustCalculated = false
            // reset inputNumber
            self.inputNumbers = ""
            // reset lastOperand
            self.latestOperand = 0
            break
            
            
        // Actions for "." button
        case .decimal:
            if value.contains(".") { return }
            if isCalculating || isJustCalculated { return }
            value += button.rawValue
            // add . to input number in expression
            if let lastCharacter = inputNumbers.last {
                if lastCharacter == "+" || lastCharacter == "-" || lastCharacter == "÷" || lastCharacter == "×" || lastCharacter == "=" {
                    self.inputNumbers += "0" + button.rawValue
                    return
                }
            } else {
                self.inputNumbers = "0" + button.rawValue
                return
            }
            self.inputNumbers += button.rawValue
            break
            
            
        // Action for "+/-" button
        case .negative:
            if value == "0" { return }
            if value.contains("-") {
                value.removeFirst()
            } else {
                value = "-" + value
            }
            break
            
        // Action for "%" button
        case .percent:
            if value == "0" { return }
            value = String(Double(value)! / 100)
            break
            
        // Action for number button
        default:
            
            // Show operation input below the displayed number
            if inputNumbers != "0" {
                self.inputNumbers += button.rawValue
            } else {
                self.inputNumbers = button.rawValue
            }
            
            // Hold input number
            self.latestOperand = Decimal(string: button.rawValue) ?? 0
            
            
            // Reset color of the basic operator
            if activeButton != nil {
                activeButton = nil
            }
            
            
            // Get number from input
            let number = button.rawValue
            
            if self.isJustCalculated {
                self.value = number
                self.isJustCalculated = false
                self.isCalculating = false
                return
            }
            
            // If some operating is running, displayed number changes
            if self.isCalculating {
                value = number
                self.isCalculating = false
                self.isJustCalculated = false
                return
            }
            
            // Display number
            if self.value == "0" {
                // deny 0 input
                if button.rawValue == "0" {
                    
                }
                value = number
            }
            else {
                self.value = "\(self.value)\(number)"
            }
            
            
        }
    }
    
    
    
    // Function to check if argument is an operator
    func isOperator(_ char: Character) -> Bool {
        return char == "+" || char == "-" || char == "÷" || char == "×"
    }
    
    
    // Function for format Decimal to String
    func formatNumber(_ num: Decimal) -> String {
        return NSDecimalNumber(decimal: num).stringValue
    }
    
    // Function that pace comma at every three number
    func addCommas(_ numberString: String) -> String {
        // Create a NumberFormatter
        let numberFormatter = NumberFormatter()
        // Set grouping separator as comma
        numberFormatter.groupingSeparator = ","
        // Set grouping size as 3
        numberFormatter.numberStyle = .decimal
        // Handle decimal numbers
        if let dotIndex = numberString.firstIndex(of: ".") {
            let integerPart = String(numberString[numberString.startIndex..<dotIndex])
            let decimalPart = String(numberString[dotIndex..<numberString.endIndex])
            if let integerNumber = numberFormatter.number(from: integerPart) {
                // new code: convert integer part of number to string with comma separators
                let formattedNumber = numberFormatter.string(from: integerNumber)! + decimalPart
                return formattedNumber
            } else {
                return numberString
            }
        } else {
            // If number is integer
            if let number = numberFormatter.number(from: numberString) {
                // new code: convert number to string with comma separators
                let formattedNumber = numberFormatter.string(from: number)!
                return formattedNumber
            } else {
                return numberString
            }
        }
    }
    
    
    // Function for calculate
    func performOperation(_ operation: Operation, on operand1: Decimal, and operand2: Decimal) -> Decimal {
        switch operation {
        case .addOp:
            return operand1 + operand2
        case .subtractOp:
            return operand1 - operand2
        case .divideOp:
            return operand1 / operand2
        case .multiplyOp:
            return operand1 * operand2
        case .none:
            return operand2
        }
    }
    
    
    // Function to insert spaces between number and operator
    func insertSpaces(_ input: String) -> String {
        var prevCharIsDigit = false
        var prevCharWasDecimal = false
        var chars: [String] = []

        for char in input {
            let currentCharIsDigit = char.isNumber
            let currentCharIsDecimal = (char == ".")

            if (!prevCharIsDigit && currentCharIsDigit && !prevCharWasDecimal) ||
               (prevCharIsDigit && !currentCharIsDigit && !currentCharIsDecimal) {
                chars.append(" ")
            }

            chars.append(String(char))
            prevCharIsDigit = currentCharIsDigit
            prevCharWasDecimal = currentCharIsDecimal
        }

        return chars.joined()
    }
    
}



#Preview {
    ContentView()
}


//struct ContentView: View {
//
////    @State private var showImmersiveSpace = false
////    @Environment(\.openImmersiveSpace) var openImmersiveSpace
////    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
//
//    @State var value: String = "0"
//    @State var runningNumber: Double = 0
//
//    @State var isCalculating: Bool = false
//    @State var isCalculated: Bool = false
//    @State var isOperating: Bool = false
//    @State var result: Double = 0
//
//    @State var currentOperation: String? = nil
//
//    let colors: [Color] = [Color.command, Color.number, Color.number, Color.number, Color.number]
//    @State var elements = ["AC", "+/-", "%", "÷", "7", "8", "9", "×", "4", "5", "6", "-", "1", "2", "3", "+"]
//
//
//    // Function that updates the number displayed
//    func buttonTapped(button: String) {
//        if let _ = Int(button) {
//
//            // If an operation is running
//            if (isCalculating) {
//                value = String(button)
//                isCalculating = false
//                return
//            }
//
//            if(isCalculated) {
//                value = String(button)
//                isCalculated = false
//                return
//            }
//
//            // If the button represents a number, update the value
//            if(value == "0") {
//                value = String(button)
//            }
//            else {
//                value += String(button)
//            }
//        } else if(button == ".") {
//            if(value.contains(".")) { return }
//            if(isCalculated) {
//                value = "0."
//                isCalculated = false
//                return
//            }
//            value += "."
//        } else if(button == "AC") {
//            value = "0"
//            runningNumber = 0
//            currentOperation = nil
//        } else if(button == "C") {
//            value = "0"
//            elements[0] = "AC"
//        } else if(button == "+/-") {
//            if (value.contains("-"))
//            {
//                value.removeFirst()
//            }
//            else {
//                value = "-" + value
//            }
//        } else if(button == "%") {
//            let percentedValue = Double(value)! / 100
//            value = String(percentedValue)
//        } else if(button == "÷") {
//            if(isOperating) {
//                let tempNumber = Double(value)!
//                result = runningNumber / tempNumber
//                return
//            }
//            isCalculating = true
//            runningNumber = Double(value)!
//            currentOperation = button
//            elements[0] = "C"
//            isOperating = true
//        } else if(button == "×") {
//            if(isOperating) {
//                let tempNumber = Double(value)!
//                result = runningNumber * tempNumber
//                return
//            }
//            isCalculating = true
//            runningNumber = Double(value)!
//            currentOperation = button
//            elements[0] = "C"
//            isOperating = true
//        } else if(button == "-") {
//            if(isOperating) {
//                let tempNumber = Double(value)!
//                result = runningNumber - tempNumber
//                return
//            }
//            isCalculating = true
//            runningNumber = Double(value)!
//            currentOperation = button
//            elements[0] = "C"
//            isOperating = true
//        } else if(button == "+") {
//            if(isOperating) {
//                let tempNumber = Double(value)!
//                result = runningNumber + tempNumber
//                return
//            }
//            isCalculating = true
//            runningNumber = Double(value)!
//            currentOperation = button
//            elements[0] = "C"
//            isOperating = true
//        }
//        else if(button == "=") {
//            let convertedValue = Double(value)!
//            if(currentOperation == "+") {
//                result = runningNumber + convertedValue
//            } else if(currentOperation == "-") {
//                result = runningNumber - convertedValue
//            } else if(currentOperation == "×") {
//                result = runningNumber * convertedValue
//            } else if(currentOperation == "÷") {
//                result = runningNumber / convertedValue
//            } else {
//                result = convertedValue
//            }
//            isCalculated = true
//        }
//        value = formatNumber(result)
//    }
//
//
//    func formatNumber(_ num: Double) -> String {
//        if num.truncatingRemainder(dividingBy: 1) == 0 {
//            return String(format: "%.0f", num)
//        } else {
//            return String(num)
//        }
//    }
//
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.black
//                VStack {
//                    HStack {
//                        // The bumber input
//                        Spacer()
//                        Text(value)
//                            .bold()
//                            .font(.system(size:40))
//                            .padding()
//                    }
//                    .frame(height: 50)
//
//                    // Buttons for Numbers and operators
//                    ForEach(0...3, id: \.self) { row in
//                        HStack {
//                            ForEach(0...3, id: \.self) { column in
//                                ZStack {
//                                    Button(action: {
//                                        // Action
//                                        self.buttonTapped(button: elements[row * 4 + column])
//                                    }) {
//                                        Text(elements[row * 4 + column])
//                                            .frame(width: 40, height: 40)
//                                            .background(isCalculating && currentOperation == elements[row * 4 + column] ? .white : (column < 3 ? colors[row] : Color.basicOperator))
//                                            .foregroundColor(isCalculating && currentOperation == elements[row * 4 + column] ? Color.basicOperator : (row == 0 && column < 3 ? .black : .white))
//                                            .clipShape(Circle())
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                    .hoverEffect(.lift)
//                                }
//                            }
//                        }
//                    }
//                    // Buttons for the bottom
//                    HStack {
//                        Button(action: {
//                            self.buttonTapped(button: "0")
//                        }) {
//                            Text("0")
//                                .frame(width: 90, height: 40)
//                                .foregroundColor(.white)
//                                .background(Color.number)
//                                .cornerRadius(50)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        Button(action: {
//                            self.buttonTapped(button: ".")
//                        }) {
//                            Text(".")
//                                .frame(width: 40, height: 40)
//                                .foregroundColor(.white)
//                                .background(Color.number)
//                                .cornerRadius(50)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        Button(action: {
//                            self.buttonTapped(button: "=")
//                        }) {
//                            Text("=")
//                                .frame(width: 40, height: 40)
//                                .foregroundColor(.white)
//                                .background(Color.basicOperator)
//                                .cornerRadius(50)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//            }
//        }
//        .frame(width: 240, height: 400)
//    }
//}
