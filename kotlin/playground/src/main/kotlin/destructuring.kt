package playground.destructuring

data class PersonId(val firstName: String, val middleName: String, val lastName: String) {
//    operator fun component1() = firstName
//    operator fun component2() = firstName
}

fun printPerson(personId: PersonId){
    val (first, last) = personId
    println("First name $first")
    println("Last name  $last")

}