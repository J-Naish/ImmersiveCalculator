//  ContentView.swift
//  ImmersiveCalculator

// TODO: Here are todos

// 3. in percent, inputNumbers does not update
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
    
    // unnecessary if inputNumbers removed
    var str: String {
        switch self {
        case .addOp:
            return "+"
        case .subtractOp:
            return "-"
        case .divideOp:
            return "÷"
        case .multiplyOp:
            return "×"
        default:
            return ""
        }
    }
}


struct ContentView : View {
    
    @State var value:String = "0"
    @State var runningNumber:Decimal = 0
    // Variable for what the running operation is
    @State var currentOperation: Operation = .none
    // Variable for changing basic operator button color
    @State var activeButton: CalcButton?
    // Boolean for check if an operator is selected
    @State var isOperatorTapped: Bool = false
    // Boolean for that number not follow the output number
    // After equal tapped it becomes true
    @State var isEqualTapped: Bool = false
    // Number input
    @State var inputNumbers: String = ""
    // Hold latest operand, variable for repeating operation with equal
    @State var latestOperand: Decimal = 0
    // Array for hold input numbers and operator
    @State var inputValues: [String] = []

    
    
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
                        .lineLimit(1)
                        .truncationMode(.head)
                        .font(.system(size:48))
                        .foregroundColor(.white)
                        .shadow(color: Color.shadowWhite, radius: 6, x: 0, y: 0)
                }
                .padding()
                
                // Expression
                HStack {
                    Spacer()
                    // TODO: inputNumbers
                    Text(insertSpacesOld(inputNumbers))
                    //Text(insertSpaces(inputValues)) // new code
                        .lineLimit(1)
                        .truncationMode(.head)
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
    
            
            
            
            // TODO: inputNumbers
            // Remove decimal point if any number follow the point
            if let lastCharacter = inputNumbers.last {
                if lastCharacter == "." {
                    // remove decimal point in expression
                    self.inputNumbers = String(inputNumbers.dropLast())
                    // remove decimal point in displayed value
                    self.value = String(value.dropLast())
                }
            }
            // TODO: new code
            if let lastValue = inputValues.last {
                if let lastCharacter = lastValue.last {
                    if lastCharacter == "." {
                        self.inputValues[inputValues.count - 1] =
                            String(self.inputValues[inputValues.count - 1].dropLast())
                        self.value = String(value.dropLast())
                    }
                }
            }
            
            
            
            // In case of +, -, ÷, ×
            if button != .equal {
                
                
                
                
                // TODO: inputNumbers
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
                // new code
                if inputValues.contains("=") {
                    self.inputValues.append(self.value)
                }
                if let lastValue = inputValues.last {
                    if lastValue == "+" || lastValue == "-" || lastValue == "÷" || lastValue == "×" {
                        self.inputValues.removeLast()
                    }
                }
                if self.value == "0" && self.inputValues.isEmpty {
                    self.inputValues.append("0")
                    self.inputValues.append(button.rawValue)
                }
                
                
                
                
                
                // Change color of selected operator button
                self.activeButton = button
                
                // Tapping operator after equal does not run operation
                if isEqualTapped {
                    self.isOperatorTapped = true
                    self.currentOperation = button.operation
                    self.runningNumber = Decimal(string: self.value) ?? 0
                    self.isEqualTapped = false
                    return
                }
                

                
                
                // Run calculation with operators
                if currentOperation != .none && !isOperatorTapped {
                    let currentValue = Decimal(string: self.value) ?? 0
                    let result = performOperation(self.currentOperation, on: self.runningNumber, and: currentValue)
                    self.value = formatNumber(result)
                }
                
                // Update bool
                self.isOperatorTapped = true
                self.isEqualTapped = false
                
                // set operation
                self.currentOperation = button.operation
                
                // value becomes runningNumber
                self.runningNumber = Decimal(string: self.value) ?? 0
                
                // In case of equal
            } else if button == .equal {
                
                
                
                
                // TODO: inputNumbers
                // If last character is an operator, repeat operation
                // i.e. "12+14+=" becomes "12+14+26=52"
                if let lastCharacter = inputNumbers.last {
                    if lastCharacter == "+" || lastCharacter == "-" || lastCharacter == "÷" || lastCharacter == "×" {
                        self.inputNumbers += self.value
                    }
                }
                // If there is no operator input, return
                if !inputNumbers.contains("+") && !inputNumbers.contains("-") &&
                    !inputNumbers.contains("÷") && !inputNumbers.contains("×") {
                    return
                }
                // new code
//                if let lastValue = inputValues.last {
//                    if lastValue == "+" || lastValue == "-" || lastValue == "÷" || lastValue == "×" {
//                        self.inputValues.append(self.value)
//                    }
//                }
//                if !inputValues.contains("+") && !inputValues.contains("-") &&
//                    !inputValues.contains("÷") && !inputValues.contains("×") {
//                    return
//                }
                
                
                
                
                
                // Repeat last operation with equal
                if isEqualTapped {
                    // Update value
                    let currentValue = Decimal(string: self.value) ?? 0
                    let result = performOperation(self.currentOperation, on: currentValue, and: self.latestOperand)
                    self.value = formatNumber(result)
                    self.runningNumber = currentValue
                    
                    
                    
                    // TODO: inputNumbers
                    inputNumbers = "\(currentValue)\(currentOperation.str)\(self.latestOperand)=\(value)"
                    // new code
                    self.inputValues.append("=")
                    self.inputValues.append(self.value)
                    return
                    
                    
                    
                }
                
                // Get latest operand
                self.latestOperand = Decimal(string: self.value) ?? 0
                
                // Get current value
                let currentValue = Decimal(string: self.value) ?? 0
                // Get result of selected operation
                let result = performOperation(self.currentOperation, on: self.runningNumber, and: currentValue)
                // Set the result to value
                self.value = formatNumber(result)
                // Update runningNumber
                self.runningNumber = currentValue
                // Reset boolean for calculating
                self.isOperatorTapped = false
                
                // Update the bool
                self.isEqualTapped = true
                
                
                
                // TODO: Show equal and result
                inputNumbers += button.rawValue + value
                // new code
                self.inputValues.append(button.rawValue)
                self.inputValues.append(self.value)
                
                
                
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
            self.isOperatorTapped = false
            self.isEqualTapped = false
            
            
            
            // TODO: reset inputNumber
            self.inputNumbers = ""
            // new code
            self.inputValues.removeAll()
            
            
            
            // reset lastOperand
            self.latestOperand = 0
            break
            
            
        // Actions for "." button
        case .decimal:
            // Ignore process if decimal point is also included
            if value.contains(".") { return }
            //
            if isEqualTapped { return }
            
            if isOperatorTapped {
                // Decimal point tapped after operator, it begins with 0
                value = "0" + button.rawValue
                self.isOperatorTapped = false
                
                
                
                
                // TODO: inputNumbers
                self.inputNumbers += "0" + button.rawValue
                // new code
                self.inputValues.append("0.")
                
                
                
                return
            }
            
            
            // Update value
            value += button.rawValue

            
            
            // TODO: inputNumbers
            if inputNumbers.isEmpty {
                inputNumbers = "0."
                return
            }
            self.inputNumbers += button.rawValue
            // new code
            if self.inputValues.isEmpty {
                self.inputValues.append("0.")
                return
            }
            if let lastValue = self.inputValues.last {
                self.inputValues[inputValues.count - 1] = lastValue + "."
            }
            
            
            
            
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
            
            // value divided by 100
            value = String(Double(value)! / 100)
            
            
            break
            
            
        // Action for number button
        default:
            
            
            
            // TODO: inputNumbers
            // Show operation input below the displayed number
            if inputNumbers != "0" {
                self.inputNumbers += button.rawValue
            } else {
                self.inputNumbers = button.rawValue
            }
            // new code
            if let lastValue = self.inputValues.last {
                if lastValue == "0" {
                    self.inputValues[inputValues.count - 1] = button.rawValue
                } else {
                    self.inputValues[inputValues.count - 1] = lastValue + button.rawValue
                }
            }
            
            
            
            // Functionality when a number is tapped after equal
            if isEqualTapped {
                self.value = button.rawValue
                
                
                
                // TODO: inputNumbers
                self.inputNumbers = button.rawValue
                // new code
                self.inputValues.removeAll()
                self.inputValues.append(button.rawValue)
                
                
                
                self.isEqualTapped = false
                self.currentOperation = .none
                return
            }
            
            
            // Reset color of the basic operator
            if activeButton != nil { activeButton = nil }
            
            
            // Get number from input
            let number = button.rawValue
            
            if self.isEqualTapped {
                self.value = number
                self.isEqualTapped = false
                self.isOperatorTapped = false
                return
            }
            
            // If some operating is running, displayed number changes
            if self.isOperatorTapped {
                value = number
                self.isOperatorTapped = false
                self.isEqualTapped = false
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
    
    
    
    
    
    // Function for format Decimal to String; Remove floating 0
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
    func insertSpacesOld(_ input: String) -> String {
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
    
    
    // Function to insert spaces between each element of array
    func insertSpaces(_ inputArray: [String]) -> String {
        return inputArray.joined(separator: " ")
    }
    
    
}



#Preview {
    ContentView()
}
