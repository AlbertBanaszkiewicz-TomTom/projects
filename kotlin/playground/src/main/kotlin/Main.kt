import playground.destructuring.PersonId
import playground.destructuring.printPerson

fun destructuring(){
    val person = PersonId(firstName = "Albert", middleName = "Piotr",
    lastName = "Banaszkiewicz")

    printPerson(person)
}
fun main(args: Array<String>) {
    destructuring()
}