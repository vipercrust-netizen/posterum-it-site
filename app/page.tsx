import Link from "next/link";
import {ArrowRight,Boxes,Server,Workflow,CheckCircle2} from "lucide-react";
import CallbackForm from "@/components/CallbackForm";

const tasks=["Доработка и обновление 1С","Ошибки и медленная работа 1С","Настройка Windows / Linux сервера","Перенос сервера или базы","Резервное копирование и мониторинг","Файловый сервер, VPN, внутренние сервисы"];

export default function Home(){
 return <>
  <section className="simpleHero">
   <div className="wrap simpleHeroGrid">
    <div>
     <div className="eyebrow">1С · СЕРВЕРЫ · IT-ИНФРАСТРУКТУРА</div>
     <h1>IT для бизнеса<br/><em>без лишней сложности</em></h1>
     <p className="lead">Дорабатываем и сопровождаем 1С, настраиваем Windows и Linux серверы, разворачиваем внутренние сервисы компании.</p>
     <div className="actions"><a className="btn" href="#callback">Обсудить задачу</a><a className="textLink" href="#services">Посмотреть услуги <ArrowRight size={17}/></a></div>
     <div className="heroFacts"><span><CheckCircle2/> Работаем с существующими системами</span><span><CheckCircle2/> Берём разовые задачи и сопровождение</span></div>
    </div>
    <div className="heroPhoto serverPhoto" aria-label="Серверная инфраструктура"/>
   </div>
  </section>

  <section className="section simpleServices" id="services"><div className="wrap">
   <div className="sectionIntro"><div className="eyebrow">УСЛУГИ</div><h2>Три направления. Один подрядчик.</h2><p>Без длинного каталога услуг: выберите направление, а конкретную задачу разберём вместе.</p></div>
   <div className="simpleCards">
    <Link href="/1c" className="simpleCard"><div className="cardPhoto photo1c"/><div className="cardText"><Boxes/><h3>1С</h3><p>Обновления, доработки, отчёты, обработки, интеграции и сопровождение.</p><span>Подробнее <ArrowRight/></span></div></Link>
    <Link href="/servers" className="simpleCard"><div className="cardPhoto serverPhoto"/><div className="cardText"><Server/><h3>Серверы</h3><p>Windows, Linux, PostgreSQL, Docker, переносы, резервные копии и мониторинг.</p><span>Подробнее <ArrowRight/></span></div></Link>
    <Link href="/infrastructure" className="simpleCard"><div className="cardPhoto infraPhoto"/><div className="cardText"><Workflow/><h3>Инфраструктура</h3><p>Файловые серверы, VPN, корпоративные сервисы, телефония и удалённый доступ.</p><span>Подробнее <ArrowRight/></span></div></Link>
   </div>
  </div></section>

  <section className="section problemSection"><div className="wrap problemGrid">
   <div><div className="eyebrow">МОЖНО ПРОСТО ОПИСАТЬ ПРОБЛЕМУ</div><h2>Не обязательно знать, какая услуга вам нужна</h2><p>Расскажите, что не работает или что хотите изменить. Разберёмся в текущей системе и предложим следующий шаг.</p></div>
   <div className="problemList">{tasks.map(x=><a href="#callback" key={x}>{x}<ArrowRight/></a>)}</div>
  </div></section>

  <section className="section howSimple"><div className="wrap">
   <div className="sectionIntro"><div className="eyebrow">КАК РАБОТАЕМ</div><h2>Понятный процесс</h2></div>
   <div className="stepsSimple"><div><b>01</b><h3>Обсуждаем</h3><p>Вы описываете задачу и текущую ситуацию.</p></div><div><b>02</b><h3>Разбираемся</h3><p>Смотрим систему, ограничения и объём работ.</p></div><div><b>03</b><h3>Делаем</h3><p>Согласовываем решение и выполняем работу.</p></div></div>
  </div></section>

  <section className="cta simpleCta" id="callback"><div className="wrap ctaGrid"><div><div className="eyebrow light">СВЯЗАТЬСЯ</div><h2>Есть задача? Давайте обсудим.</h2><p>Оставьте телефон и пару слов о задаче. Этого достаточно для начала.</p></div><CallbackForm/></div></section>
 </>;
}